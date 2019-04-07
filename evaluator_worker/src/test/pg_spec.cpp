#define BOOST_TEST_MODULE pg_ctx spec - pg functions spec
#include <boost/test/unit_test.hpp>
#include "db/types.h"
#include <string>

using namespace evworker::db;

struct ConnectionInformation {
  static const std::string host;
  static const std::string db;
  static const std::string user;
  static const std::string password;
  static const int port;


};
const std::string ConnectionInformation::host = "127.0.0.1";
const std::string ConnectionInformation::db = "evaluator_api_development";
const std::string ConnectionInformation::user = "evaluator_api";
const std::string ConnectionInformation::password = "password";
const int ConnectionInformation::port = 5432;
BOOST_TEST_GLOBAL_FIXTURE(ConnectionInformation);

BOOST_AUTO_TEST_SUITE(pg_tests)


BOOST_AUTO_TEST_CASE(establish_connection) {
  
  pg_ctx pg(ConnectionInformation::host, ConnectionInformation::port, ConnectionInformation::db, 
  ConnectionInformation::user, ConnectionInformation::password);
  BOOST_TEST(static_cast<bool>(pg));
}



BOOST_AUTO_TEST_SUITE_END()

struct PGConnectionContext {
  pg_ctx pg;
  PGConnectionContext() :  pg(ConnectionInformation::host, ConnectionInformation::port, ConnectionInformation::db, 
  ConnectionInformation::user, ConnectionInformation::password) {}
};

BOOST_FIXTURE_TEST_SUITE(query_tests, PGConnectionContext)

BOOST_AUTO_TEST_CASE(find_project) {
  project_t project;
  BOOST_TEST(pg.find_project(1, project));
  BOOST_TEST(project.id == 1);
  BOOST_TEST(project.spec_type().isJavaType());
  BOOST_TEST((project.subtype().junitVersion == evspec::JUnitVersion::JUnit_4));
}

BOOST_AUTO_TEST_CASE(non_existant_project) {
  project_t project;
  BOOST_TEST(!pg.find_project(512, project));
}

BOOST_AUTO_TEST_CASE(find_submission) {
  submission_t submission;
  BOOST_TEST(pg.find_submission(1, submission));
  BOOST_TEST(submission.team == "neon kitty");
  BOOST_TEST(submission.file_name == "csv_submission.zip");
}

BOOST_AUTO_TEST_CASE(non_existant_submission) {
  submission_t submission;
  BOOST_TEST(!pg.find_submission(512, submission));
}


BOOST_AUTO_TEST_CASE(find_test_suite) {
  test_suite_t suite;
  BOOST_TEST(pg.find_testsuite(1, suite));
  BOOST_TEST(suite.name == "public_suite");
  BOOST_TEST(suite.hidden == true);
  BOOST_TEST(suite.timeout == 60);
  BOOST_TEST(suite.file_name == "M1PrivateTest.zip");
  BOOST_TEST(suite.package_name() == "public");
}

BOOST_AUTO_TEST_CASE(find_non_existant_suite) {
  test_suite_t suite;
  BOOST_TEST(!pg.find_testsuite(512, suite));
}

BOOST_AUTO_TEST_CASE(list_suites) {
  std::vector<test_suite_t> suites;
  BOOST_TEST(pg.find_testsuites(1, suites));
  BOOST_TEST(suites.size() == 2);
}

BOOST_AUTO_TEST_CASE(list_non_existant_project_suites) {
  std::vector<test_suite_t> suites;
  BOOST_TEST(!pg.find_testsuites(512, suites));
  BOOST_TEST(suites.size() == 0);
}

BOOST_AUTO_TEST_CASE(list_project_without_suites_suites) {
  std::vector<test_suite_t> suites;
  BOOST_TEST(!pg.find_testsuites(2, suites));
  BOOST_TEST(suites.size() == 0);

}

BOOST_AUTO_TEST_SUITE_END()
