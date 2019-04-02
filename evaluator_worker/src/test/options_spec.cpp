#define BOOST_TEST_MODULE ev_worker_spec - option configuration spec
#include <boost/test/unit_test.hpp>
#include <filesystem>
#include "options.h"
#include "uuid/uuid.h"
BOOST_AUTO_TEST_SUITE(options)

BOOST_AUTO_TEST_CASE(file_parsing_test_daemon) {
  std::filesystem::path config_file("fixtures/sample_config.ini");
  const char* argv[]{"please/ignore/exe/path", "-C", config_file.c_str()};
  evworker::options::variables_map vm;
  BOOST_REQUIRE_NO_THROW(vm = evworker::options::parse_options(true, 3, argv));
  BOOST_TEST(vm[evworker::options::NUM_WORKERS]
                 .as<evworker::options::num_workers_t>() == 4);
  BOOST_TEST(
      vm[evworker::options::REDIS_HOST].as<evworker::options::redis_host_t>() ==
      "localhost");
  BOOST_TEST(
      vm[evworker::options::REDIS_PORT].as<evworker::options::redis_port_t>() ==
      6379);
  BOOST_TEST(vm[evworker::options::SUBMISSION_BASE_PATH].as<std::string>() ==
             "fixtures/submissions");
  BOOST_TEST(vm[evworker::options::PID_DIRECTORY].as<std::string>() ==
             "tmp/run/evworker");
}

BOOST_AUTO_TEST_CASE(option_parsing_test_worker) {
  std::filesystem::path config_file("fixtures/sample_config.ini");
  uuid_t daemon_uuid;
  uuid_generate(daemon_uuid);
  char uuid_cstr[UUID_STR_LEN]{0};
  uuid_unparse_lower(daemon_uuid, uuid_cstr);
  const char* argv[]{"please/ignore/exe/path", "-C", config_file.c_str(),
                     "--uuid", uuid_cstr};
  evworker::options::variables_map vm;
  vm = evworker::options::parse_options(false, 5, argv);
  BOOST_TEST(vm[evworker::options::NUM_WORKERS]
                 .as<evworker::options::num_workers_t>() == 4);
  BOOST_TEST(
      vm[evworker::options::REDIS_HOST].as<evworker::options::redis_host_t>() ==
      "localhost");
  BOOST_TEST(
      vm[evworker::options::REDIS_PORT].as<evworker::options::redis_port_t>() ==
      6379);
  BOOST_TEST(vm[evworker::options::SUITES_BASE_PATH].as<std::string>() ==
             "fixtures/test_suites");
  BOOST_TEST(vm[evworker::options::PID_DIRECTORY].as<std::string>() ==
             "tmp/run/evworker");
  BOOST_TEST(vm[evworker::options::PARENT_UUID].as<std::string>() == uuid_cstr);
}

BOOST_AUTO_TEST_CASE(file_parsing_test_daemon_bad_config) {
  std::filesystem::path config_file("fixtures/bad_cofig.ini");
  const char* argv[]{"please/ignore/exe/path", "-C", config_file.c_str()};
  evworker::options::variables_map vm;
  BOOST_REQUIRE_THROW(vm = evworker::options::parse_options(true, 3, argv),
                      std::exception);
}
BOOST_AUTO_TEST_SUITE_END()
