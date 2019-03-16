#define BOOST_TEST_MODULE evspec - java project evaluation
#include "evspec.h"
#include <boost/filesystem.hpp>
#include <boost/test/included/unit_test.hpp>
#include <forward_list>
#include <iterator>
#include <libxml2/libxml/parser.h>
#include <algorithm>

namespace fs = boost::filesystem;

struct libXmlInitContext {
  libXmlInitContext() { xmlInitParser(); }
  ~libXmlInitContext() { xmlCleanupParser(); }
};

struct JavaTestContext {
  fs::path srcPath;
  std::forward_list<evspec::TestSuite> suites;
  evspec::Spec spec;
  JavaTestContext()
      : srcPath(fs::canonical("fixtures/M2_Code.zip")),
        suites({{.path = fs::canonical("fixtures/publictests.zip")},
                {.path = fs::canonical("fixtures/privatetests.zip")}}),
        spec(srcPath, suites, evspec::SpecType::JAVA_1_8,
             {.junitVersion = evspec::JUnitVersion::JUnit_4}) {
               BOOST_TEST_MESSAGE("JavaTestContext created");
             }
};

BOOST_TEST_GLOBAL_FIXTURE(libXmlInitContext);

BOOST_FIXTURE_TEST_SUITE(java_tests, JavaTestContext)

BOOST_AUTO_TEST_CASE(suite_compiles) {
  const evspec::Result *result;
  BOOST_REQUIRE_NO_THROW(result = spec.run());
  BOOST_TEST(result != nullptr);
  BOOST_TEST(result->compiled());
  BOOST_TEST(result->srcCompilerErr.empty());
  BOOST_TEST(result->testCompilerErr.empty());
}

BOOST_AUTO_TEST_CASE(generated_results_for_two_test_suites) {
  const evspec::Result *result = spec.run();
  BOOST_TEST(result != nullptr);

  int count =
      std::distance(std::begin(result->results), std::end(result->results));
  BOOST_TEST(count == 2);
}

BOOST_AUTO_TEST_CASE(generated_results_correctly_for_public_suite) {
  const evspec::Result *result = spec.run();
  BOOST_TEST(result != nullptr);

  const evspec::SuiteResult *publicSuiteResult = nullptr;
  for (auto &sr : result->results) {
    if (sr.packageName == std::string("publictests")) {
      publicSuiteResult = &sr;
    }
  }
  BOOST_TEST(publicSuiteResult != nullptr);
  BOOST_TEST(publicSuiteResult->numCases == 254);
  std::ptrdiff_t testCasesLen = std::distance(std::begin(publicSuiteResult->testCases), std::end(publicSuiteResult->testCases));
  BOOST_TEST(testCasesLen == publicSuiteResult->numCases);
    std::ptrdiff_t failCount = std::count_if(std::begin(publicSuiteResult->testCases), std::end(publicSuiteResult->testCases), [](const evspec::TestCaseResult &tcr) {
    return !tcr.success();
  });
  BOOST_TEST(failCount == 0);
}

BOOST_AUTO_TEST_CASE(generated_results_correctly_for_private_suite) {
  const evspec::Result *result = spec.run();
  BOOST_TEST(result != nullptr);
  const evspec::SuiteResult *privateSuiteResult = nullptr;
  for (auto &sr : result->results) {
    if (sr.packageName == std::string("privatetests")) {
      privateSuiteResult = &sr;
    }
  }
  BOOST_TEST(privateSuiteResult != nullptr);
    BOOST_TEST(privateSuiteResult->numCases == 73);
  std::ptrdiff_t testCasesLen = std::distance(std::begin(privateSuiteResult->testCases), std::end(privateSuiteResult->testCases));
  BOOST_TEST(testCasesLen == privateSuiteResult->numCases);
  std::ptrdiff_t failCount = std::count_if(std::begin(privateSuiteResult->testCases), std::end(privateSuiteResult->testCases), [](const evspec::TestCaseResult &tcr) {
    return !tcr.success();
  });
  BOOST_TEST(failCount == 1);
}

BOOST_AUTO_TEST_SUITE_END()
