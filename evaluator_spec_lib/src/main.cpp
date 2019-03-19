#include <algorithm>
#include <boost/filesystem.hpp>
#include <csignal>
#include <cstdlib>
#include <evspec.h>
#include <exception>
#include <forward_list>
#include <iostream>
#include <iterator>
#include <libxml2/libxml/parser.h>

void print_exception(const std::exception &e) {
  try {
    std::cerr << "exception: " << e.what() << '\n';
    std::rethrow_if_nested(e);
  } catch (const std::exception &e) {
    print_exception(e);
  }
}

using namespace boost::filesystem;

int main([[maybe_unused]] int argc, [[maybe_unused]] char const *argv[]) {
  std::atexit(evspec::exitHandler);
  std::signal(SIGABRT, evspec::abortHandler);
  xmlInitParser();
  try {
    path srcPath = canonical("fixtures/M2_Code.zip");
    std::forward_list<evspec::TestSuite> suites;
    suites.push_front({.path = canonical("fixtures/publictests.zip")});
    suites.push_front({.path = canonical("fixtures/privatetests.zip")});
    evspec::EvaluationContext ctx = {.srcPath = srcPath,
                                     .suites = suites,
                                     .specType = evspec::SpecType::JAVA_1_8,
                                     .subtype = evspec::JUnitVersion::JUnit_4};
    const evspec::Result result = evspec::evaluateSubmission(&ctx, nullptr);
    std::cout << "Compile src errors \n" << result.srcCompilerErr
      << "\nCompile test errors\n" << result.testCompilerErr << std::endl;

    if(result.compiled()) {
      for(const evspec::SuiteResult &sr : result.results) {
        std::cout << "Package name" << sr.packageName << '\n';
        std::cout << "Number of cases " << sr.numCases << '\n';
        std::transform(std::begin(sr.testCases), std::end(sr.testCases),
        std::ostream_iterator<std::string>(std::cout), [](const
        evspec::TestCaseResult &tc) {
          std::string out(tc.className);
          out += '.' + tc.name + '\n' + std::to_string(tc.timeTaken) + '\n';
          if(!tc.success()) {
            out += tc.failureReason + '\n';
          }
          return out;
        });
      }
    }

  } catch (const std::exception &e) {
    print_exception(e);
    return EXIT_FAILURE;
  }
  xmlCleanupParser();
}
