#include <string>
#include "db/helpers.h"
#include "db/types.h"
#include "options.h"

namespace evworker::db {
fs::path test_suite_t::get_path(
    const boost::program_options::variables_map *config) const {
  fs::path path(config->at(options::SUITES_BASE_PATH).as<std::string>());
  path /= std::to_string(project_id) + "_" + std::to_string(id);
  path += fs::path(file_name).extension();
  return path;
}

static const std::string TEST_SUITE_BASE_QUERY =
    R"SQL(SELECT id, project_id, file_name, timeout, name, detail, hidden FROM test_suites )SQL";

static const std::string TEST_SUITES_QUERY =
    TEST_SUITE_BASE_QUERY + R"SQL( WHERE project_id = $1::int8 )SQL";

static const std::string TEST_SUITES_FIND_QUERY =
    TEST_SUITE_BASE_QUERY + R"SQL( WHERE id = $1::int8 LIMIT 1 )SQL";

void pg_ctx::parse(test_suite_t &test_suite, pg_result_t &result,
                   int tuple_index) {
  int id_fnum = PQfnumber(result, "id"),
      project_id_fnum = PQfnumber(result, "project_id"),
      file_name_fnum = PQfnumber(result, "file_name"),
      timeout_fnum = PQfnumber(result, "timeout"),
      hidden_fnum = PQfnumber(result, "hidden"),
      name_fnum = PQfnumber(result, "name"),
      detail_fnum = PQfnumber(result, "detail");
  if ((id_fnum | project_id_fnum | hidden_fnum | file_name_fnum | name_fnum |
       timeout_fnum | detail_fnum) < 0) {
    throw std::runtime_error(
        "pg_ctx::parse result : unable to get field numbers");
  }

  binary_from_column(test_suite.id, result, tuple_index, id_fnum);
  binary_from_column(test_suite.project_id, result, tuple_index,
                     project_id_fnum);
  binary_from_column(test_suite.timeout, result, tuple_index, timeout_fnum);
  int8_t hidden_proxy;
  binary_from_column(hidden_proxy, result, tuple_index, hidden_fnum);
  test_suite.hidden = hidden_proxy != 0;
  test_suite.name = text_from_column(result, tuple_index, name_fnum);
  test_suite.file_name = text_from_column(result, tuple_index, file_name_fnum);
  json_from_column(test_suite.detail, result, tuple_index, detail_fnum);
}
bool pg_ctx::find_testsuite(std::uint64_t id, test_suite_t &test_suite) {
  std::uint64_t id_network_order = native_to_big(id);
  char *param_values[]{(char *)&id_network_order};
  int param_lengths[]{sizeof(id_network_order)};
  int param_formats[]{1};
  pg_result_t result =
      PQexecParams(conn_, TEST_SUITES_FIND_QUERY.c_str(), 1, nullptr,
                   param_values, param_lengths, param_formats, 1);
  if ((result == PGRES_TUPLES_OK) && (PQntuples(result)) == 1) {
    parse(test_suite, result);
    return true;

  } else {
    return false;
  }
}
bool pg_ctx::find_testsuites(std::uint64_t project_id,
                             std::vector<test_suite_t> &suites) {
  std::uint64_t id_network_order = native_to_big(project_id);
  char *param_values[]{(char *)&id_network_order};
  int param_lengths[]{sizeof(id_network_order)};
  int param_formats[]{1};
  pg_result_t result =
      PQexecParams(conn_, TEST_SUITES_QUERY.c_str(), 1, nullptr, param_values,
                   param_lengths, param_formats, 1);
  if (result == PGRES_TUPLES_OK) {
    int num_tuples = PQntuples(result);
    if(num_tuples < 1) {
      return false;
    }
    std::size_t vec_offset = suites.size();
    if (vec_offset > 0) {
      vec_offset -= 1;
    }
    suites.resize(suites.size() + num_tuples);
    for (int tuple_index = 0; tuple_index < num_tuples; tuple_index++) {
      parse(suites[tuple_index + vec_offset], result, tuple_index);
    }
    return true;
  } else {
    return false;
  }
}

}  // namespace evworker::db