#include "java.h"
#include <algorithm>
#include <cstdlib>
#include <exception>
#include <forward_list>
#include <iterator>
#include <libxml2/libxml/xmlreader.h>
#include <memory>
#include <stdexcept>
#include <string>
#include <iostream>
#include <boost/regex.hpp>


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

static void processNode(evspec::Result &result, const fs::path &filepath,
                        xmlNodePtr node) {
  if (node->type != XML_ELEMENT_NODE || node->children == nullptr ||xmlStrcmp(node->name, (const xmlChar *)TEST_SUITE_NODE_NAME) != 0) {
    // ignore
    return;
  }
  result.results.emplace_front();
  evspec::SuiteResult &sr = result.results.front();
  static const boost::regex packageNamePattern(R"REGEX(^TEST-([[:alnum:]]+)\..+$)REGEX");
  boost::smatch packageNameSearch;
  std::string stem = filepath.stem().string();
  if(boost::regex_search(stem, packageNameSearch, packageNamePattern)) {
    sr.packageName.reserve(packageNameSearch[1].length());
    std::copy(packageNameSearch[1].first, packageNameSearch[1].second, std::back_inserter(sr.packageName));
  } else {
    sr.packageName = filepath.stem().string();
  }
  
  // iterate over children
  for (xmlNodePtr currentNode = node->children; currentNode;
       currentNode = currentNode->next) {
    if (currentNode->type != XML_ELEMENT_NODE || xmlStrcmp(currentNode->name, (const xmlChar *)TEST_CASE_NAME) != 0) {
      continue;
    }
    // parse test case
    xmlChar *name, *className, *timeTaken;
    name = xmlGetProp(currentNode, (const xmlChar *)"name");
    className = xmlGetProp(currentNode, (const xmlChar *)"classname");
    timeTaken = xmlGetProp(currentNode, (const xmlChar *)"time");
    sr.testCases.emplace_front();
    evspec::TestCaseResult &tcr = sr.testCases.front();
    tcr.name = (const char *)name;
    tcr.className = (const char *)className;
    tcr.timeTaken = std::atof((const char *)timeTaken);
    xmlFree(name);
    xmlFree(className);
    xmlFree(timeTaken);
    sr.numCases++;
    if (currentNode->children != nullptr) {

      xmlNodePtr failureNode = currentNode->children;
      while(failureNode != nullptr && xmlStrcmp(failureNode->name, (xmlChar *) "failure") != 0) {
        failureNode = failureNode->next;
      }
      if(failureNode == nullptr) {
        continue;
      }
      xmlChar *message = xmlGetProp(failureNode, (const xmlChar *)"message");
      sr.testCases.front().failureReason = (char *)message;
      xmlFree(message);
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
        throw std::runtime_error("Failed to "
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