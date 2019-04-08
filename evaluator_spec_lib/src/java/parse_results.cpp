#include <libxml2/libxml/xmlreader.h>
#include <algorithm>
#include <atomic>
#include <boost/regex.hpp>
#include <cstdlib>
#include <exception>
#include <forward_list>
#include <functional>
#include <iostream>
#include <iterator>
#include <memory>
#include <optional>
#include <stdexcept>
#include <string>
#include <thread>
#include <vector>
#include "boost/asio.hpp"
#include "internal/java.h"

const char *TEST_SUITE_NODE_NAME = "testsuite";
const char *TEST_CASE_NAME = "testcase";

static void textReaderDeleter(xmlTextReader *ptr) {
  if (ptr != nullptr) {
    /*
     * Since we've called xmlTextReaderCurrentDoc, we now have to
     * clean up after ourselves.  We only have to do this the last
     * time, because xmlReaderNewFile calls xmlCtxtReset which takes
     * care of it.
     */
    xmlDocPtr docPtr = xmlTextReaderCurrentDoc(ptr);
    if (docPtr) {
      xmlFreeDoc(docPtr);
    }
    xmlFreeTextReader(ptr);
  }
}



std::size_t countNodes(xmlNodePtr ptr) {
  std::size_t num = 0;
  while (ptr != nullptr) {
    num++;
    ptr = ptr->next;
  }
  return num;
}

struct wrapper_t {
  evspec::TestCaseResult testCaseResult;
  bool valid{false};
};

static void processNodeHelper(std::atomic_size_t &num_cases,
                              std::vector<wrapper_t> &out, xmlNodePtr current,
                              std::size_t start_index, std::size_t end_index) {
  for (std::size_t i = start_index; (i < end_index) & (current != nullptr);
       i++, current = current->next) {
    if (current->type != XML_ELEMENT_NODE ||
        xmlStrcmp(current->name, (const xmlChar *)TEST_CASE_NAME) != 0) {
      continue;
    }
    assert(i < out.size());
    out[i].valid = true;
    xmlChar *name, *className, *timeTaken;
    name = xmlGetProp(static_cast<xmlNode *>(current), (const xmlChar *)"name");
    className = xmlGetProp(static_cast<xmlNode *>(current),
                           (const xmlChar *)"classname");
    timeTaken =
        xmlGetProp(static_cast<xmlNode *>(current), (const xmlChar *)"time");

    out[i].testCaseResult.name = (const char *)name;
    out[i].testCaseResult.className = (const char *)className;
    out[i].testCaseResult.timeTaken = std::atof((const char *)timeTaken);
    num_cases.fetch_add(1, std::memory_order_relaxed);
    xmlFree(name);
    xmlFree(className);
    xmlFree(timeTaken);
    // Check if failure
    if (current->children != nullptr) {
      xmlNodePtr failureNode = current->children;
      while (failureNode != nullptr &&
             xmlStrcmp(failureNode->name, (xmlChar *)"failure") != 0) {
        failureNode = failureNode->next;
      }
      if (failureNode == nullptr) {
        continue;
      }
      xmlChar *message = xmlGetProp(failureNode, (const xmlChar *)"message");
      out[i].testCaseResult.failureReason = (const char *)message;
      xmlFree(message);
    }
  }
}

static void processNode(evspec::Result &result, const fs::path &filepath,
                        xmlNodePtr node) {
  if (node->type != XML_ELEMENT_NODE || node->children == nullptr ||
      xmlStrcmp(node->name, (const xmlChar *)TEST_SUITE_NODE_NAME) != 0) {
    // ignore
    return;
  }
  evspec::SuiteResult &suite_result = result.results.emplace_front();
  static const boost::regex packageNamePattern(
      R"REGEX(^TEST-([[:alnum:]]+)\..+$)REGEX");
  boost::smatch packageNameSearch;
  std::string stem = filepath.stem().string();
  if (boost::regex_search(stem, packageNameSearch, packageNamePattern)) {
    suite_result.packageName.reserve(packageNameSearch[1].length());
    std::copy(packageNameSearch[1].first, packageNameSearch[1].second,
              std::back_inserter(suite_result.packageName));
  } else {
    suite_result.packageName = filepath.stem().string();
  }
  std::size_t numNodes = countNodes(node->children);
  std::atomic_size_t num_cases = {0};
  const std::size_t thread_count =
      std::max(std::thread::hardware_concurrency(), 2U);
  const std::size_t chunk_size = numNodes / thread_count;

  boost::asio::thread_pool pool(thread_count);

  std::vector<wrapper_t> testCaseBuffer(numNodes);

  xmlNodePtr current = node->children;
  for (std::size_t i = 0; (i < numNodes) & (current != nullptr);
       i += chunk_size) {
    std::size_t count = std::min(chunk_size, numNodes - i);
    auto processHelperFunc =
        std::bind(processNodeHelper, std::ref(num_cases),
                  std::ref(testCaseBuffer), current, i, i + count);
    if (count == chunk_size) {
      boost::asio::post(pool, processHelperFunc);

    } else {
      processHelperFunc();
      break;
    }
    for (std::size_t j = 0; (j < count) & (current != nullptr); j++) {
      current = current->next;
    }
  }
  pool.join();
  suite_result.numCases = num_cases.load(std::memory_order_relaxed);
  suite_result.testCases.reserve(suite_result.numCases);
  for (auto &val : testCaseBuffer) {
    if (val.valid) {
      suite_result.testCases.emplace_back(val.testCaseResult);
    }
  }
}

static void processReportFile(evspec::Result &result, const fs::path &filepath,
                              xmlTextReader *readerPtr) {
  while (xmlTextReaderRead(readerPtr)) {
    xmlNodePtr node = xmlTextReaderExpand(readerPtr);
    if (node == nullptr) {
      throw std::runtime_error("Error while expanding node");
    }
    processNode(result, filepath, node);
  }
}

void evspec::java::parseTestResults(evspec::Result &result,
                                    const fs::path &workingDirectory) try {
  // wrap in unique ptr for RAII
  std::unique_ptr<xmlTextReader, decltype(&textReaderDeleter)> readerPtr(
      nullptr, textReaderDeleter);

  const fs::path reportsDirectory =
      workingDirectory / fs::path("target") / fs::path("surefire-reports");
  fs::directory_iterator reportsIterator(reportsDirectory);
  std::forward_list<fs::path> reportFiles;
  std::copy_if(fs::directory_iterator(reportsDirectory),
               fs::directory_iterator(), std::front_inserter(reportFiles),
               [](const fs::directory_entry &entry) {
                 const fs::path &path = entry.path();
                 return path.has_extension() && path.extension() == ".xml";
               });
  for (auto &path : reportFiles) {
    if (readerPtr == nullptr) {
      // first time init
      readerPtr.reset(xmlReaderForFile(path.c_str(), nullptr, 0));
      if (readerPtr == nullptr) {
        throw std::runtime_error(" Failed to create xmlReader");
      }
    } else {
      // resuse reader
      if (xmlReaderNewFile(readerPtr.get(), path.c_str(), nullptr, 0) == -1) {
        throw std::runtime_error(
            "Failed to "
            "assign new file to xmlReader");
      }
    }
    // xmlreader initialized
    processReportFile(result, path, readerPtr.get());
  }
} catch (...) {
  std::throw_with_nested(
      std::runtime_error("evspec::java::parseTestResults :"));
}
