#include <algorithm>
#include <exception>
#include <map>
#include <memory>
#include <sstream>
#include <stdexcept>
#include <string>
#include "db/types.h"

namespace evworker::db {

pg_ctx::pg_ctx(const std::string &host, int port, const std::string &db,
               const std::string &user, const std::string &password) try {
  std::ostringstream ostream;
  if (host[0] < 'A') {
    // ip
    ostream << "hostaddr=" << host;
  } else {
    // hostname
    ostream << "host=" << host;
  }
  ostream << ' ' << "port=" << port << ' ' << "dbname=" << db << ' '
          << "user=" << user << ' ' << "password=" << password;
  std::string conn_str = ostream.str();
  conn_ = PQconnectdb(conn_str.c_str());
  if (PQstatus(conn_) != CONNECTION_OK) {
    std::string error(PQerrorMessage(conn_));
    freeConn();
    throw std::runtime_error("failed to connect to pg server -  " + error);
  }

} catch (...) {
  std::throw_with_nested(std::runtime_error("pg_ctx: constructor exception"));
}

pg_ctx::operator bool() const { return PQstatus(conn_) == CONNECTION_OK; }

void pg_ctx::save_result(const evspec::Result &result,
                         const db::submission_t &submission,
                         const std::vector<db::test_suite_t> &suites) {
  static const std::map<std::string, std::size_t> FIELD_POS_MAP = {
      {"submission_id", 0}, {"project_id", 1}, {"test_suite_id", 2},
      {"submitter_id", 3},  {"team", 4},       {"max_grade", 5},
      {"grade", 6},         {"success", 7},    {"hidden", 8},
      {"detail", 9}};

  std::string sql =
      R"SQL(INSERT INTO results (submission_id, project_id, test_suite_id,
  submitter_id, team, max_grade, grade, success, hidden, detail) VALUES 
  )SQL";
  // build suite result -> suite lookup table
  std::map<std::string, std::size_t> package_name_index_lookup;
  for (std::size_t i = 0; i < suites.size(); i++) {
    package_name_index_lookup[suites[i].name] = i;
  }
  // each result needs to be linked to suite
  constexpr std::size_t NUM_VALUES = 10;
  std::vector<std::string> output_buffer;
  output_buffer.resize(NUM_VALUES * package_name_index_lookup.size());

  for (auto &suite_result : result.results) {
    std::size_t grade = 0;
    // Process each results
    const std::size_t suite_index =
        package_name_index_lookup[suite_result.packageName];

    auto &suite = suites[suite_index];

    output_buffer[suite_index + FIELD_POS_MAP.at("test_suite_id")] =
        std::to_string(suite.id);
    output_buffer[suite_index + FIELD_POS_MAP.at("project_id")] =
        std::to_string(suite.project_id);
    output_buffer[suite_index + FIELD_POS_MAP.at("hidden")] =
        std::to_string(suite.hidden);
    output_buffer[suite_index + FIELD_POS_MAP.at("submission_id")] =
        std::to_string(submission.id);
    output_buffer[suite_index + FIELD_POS_MAP.at("submitter_id")] =
        std::to_string(submission.submitter_id);
    output_buffer[suite_index + FIELD_POS_MAP.at("team")] =
        submission.team.empty() ? "NULL" : submission.team;
    output_buffer[suite_index + FIELD_POS_MAP.at("max_grade")] =
        std::to_string(suite_result.numCases);
    nlohmann::json detail;
    detail["src_compile_err"] = result.srcCompilerErr;
    detail["test_compile_err"] = result.testCompilerErr;
    detail["compiled"] = result.compiled();
    bool result_success = false;
    // test_cases will be stored as result.detail it contains the individual
    // test_cases
    detail["test_cases"] = nlohmann::json::array();
    nlohmann::json &test_cases = detail["test_cases"];
    for (auto &test_case_result : suite_result.testCases) {
      // process each test case
      test_cases.emplace_back(nlohmann::json());
      nlohmann::json &test_case = test_cases.back();
      test_case["success"] = test_case_result.success();
      test_case["name"] = test_case_result.name;
      test_case["class_name"] = test_case_result.className;
      test_case["time_taken"] = test_case_result.timeTaken;
      if (!test_case_result.success()) {
        test_case["failure_reason"] = test_case_result.failureReason;
      } else {
        grade += 1;
      }
      result_success &= test_case_result.success();
    }

    output_buffer[suite_index + FIELD_POS_MAP.at("success")] =
        std::to_string(result_success);
    output_buffer[suite_index + FIELD_POS_MAP.at("grade")] =
        std::to_string(result_success);
    output_buffer[suite_index + FIELD_POS_MAP.at("detail")] = detail.dump();
    sql += " ( ";
    for (std::size_t n = 1; n < NUM_VALUES; n++) {
      sql += "$" + std::to_string(suite_index + n) + ", ";
    }
    sql += "$" + std::to_string(suite_index + NUM_VALUES);
    sql += " ) ";
  }
  // After processing all suite results

  std::vector<const char *> data;
  data.reserve(output_buffer.size());
  for (auto &val : output_buffer) {
    data.push_back(val.c_str());
  }
  pg_result_t pg_result = PQexecParams(
      conn_, sql.c_str(), NUM_VALUES * package_name_index_lookup.size(),
      nullptr, data.data(), nullptr, nullptr, 0);
  if (pg_result != PGRES_COMMAND_OK) {
    throw std::runtime_error("Unable to insert sql : " + sql);
  }
}

}  // namespace evworker::db
