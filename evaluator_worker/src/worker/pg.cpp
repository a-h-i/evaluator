#include <boost/endian/conversion.hpp>
#include <exception>
#include <memory>
#include <sstream>
#include <stdexcept>
#include <string>
#include "json.hpp"
#include "pg_ctx.h"

using boost::endian::big_to_native;
using boost::endian::big_to_native_inplace;
using boost::endian::native_to_big;
using boost::endian::native_to_big_inplace;
using nlohmann::json;

static const char *SUBMISSION_FIND_QUERY = R"SQL(
  SELECT id, project_id, submitter_id, file_name, team FROM submissions WHERE id = $1::int8 LIMIT 1
)SQL";
static const char *TEST_SUITES_QUERY = R"SQL(
  SELECT id, project_id, detail, file_name, timeout, hidden FROM test_suites WHERE project_id = $1::int8
)SQL";

static const char *TEST_SUITES_FIND_QUERY = R"SQL(
  SELECT id, project_id, detail, file_name, timeout, hidden FROM test_suites WHERE id = $1::int8 LIMIT 1
)SQL";

namespace evworker::db {

template <typename Numeric>
static void binary_from_column(Numeric &dest, pg_result_t &result,
                               int tuple_index, int field_index) {
  dest = big_to_native(*reinterpret_cast<Numeric *>(
      PQgetvalue(result, tuple_index, field_index)));
}

static std::string text_from_column(pg_result_t &result, int tuple_index,
                                    int field_index) {
  if (PQgetisnull(result, tuple_index, field_index) == 1) {
    return std::string();
  } else {
    return std::string((char *)PQgetvalue(result, tuple_index, field_index));
  }
}
static void json_from_column(json &j, pg_result_t &result, int tuple_index,
                             int field_index) {
  if (PQgetisnull(result, tuple_index, field_index) == 1) {
    j.clear();
    return;
  }
  int len = PQgetlength(result, tuple_index, field_index);
  std::unique_ptr<char[]> buff(new char[len + 1]);
  char *json_binary = PQgetvalue(result, tuple_index, field_index);
  std::memcpy(buff.get(), json_binary, len);
  buff[len] = 0;
  j = json::parse(buff.get());
}
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

void pg_ctx::parse(submission_t &submission, pg_result_t &result,
                   int tuple_index) {
  int id_fnum, project_id_fnum, submitter_id_fnum, file_name_fnum, team_fnum,
      created_at_fnum;
  id_fnum = PQfnumber(result, "id");
  submitter_id_fnum = PQfnumber(result, "submitter_id");
  project_id_fnum = PQfnumber(result, "project_id");
  file_name_fnum = PQfnumber(result, "file_name");
  team_fnum = PQfnumber(result, "team");
  created_at_fnum = PQfnumber(result, "created_at");
  if ((id_fnum | submitter_id_fnum | project_id_fnum | file_name_fnum |
       team_fnum | created_at_fnum) < 0) {
    throw std::runtime_error(
        "pg_ctx::parse submission : unable to get field numbers");
  }

  binary_from_column(submission.id, result, tuple_index, id_fnum);
  binary_from_column(submission.project_id, result, tuple_index,
                     project_id_fnum);
  binary_from_column(submission.submitter_id, result, tuple_index,
                     submitter_id_fnum);
  binary_from_column(submission.created_at, result, tuple_index,
                     created_at_fnum);
  submission.file_name = text_from_column(result, tuple_index, file_name_fnum);
  submission.team = text_from_column(result, tuple_index, team_fnum);
}
bool pg_ctx::find_submission(std::uint64_t id, submission_t &submission) {
  std::uint64_t id_network_order = native_to_big(id);
  char *param_values[]{(char *)&id_network_order};
  int param_lengths[]{sizeof(id_network_order)};
  int param_formats[]{1};

  pg_result_t result =
      PQexecParams(conn_, SUBMISSION_FIND_QUERY, 1, nullptr, param_values,
                   param_lengths, param_formats, 1);
  if (result == PGRES_TUPLES_OK || PQntuples(result) == 1) {
    parse(submission, result);
    return true;

  } else {
    return false;
  }
}
void pg_ctx::parse(test_suite_t &test_suite, pg_result_t &result,
                   int tuple_index) {
  int id_fnum = PQfnumber(result, "id"),
      project_id_fnum = PQfnumber(result, "project_id"),
      file_name_fnum = PQfnumber(result, "file_name"),
      detail_fnum = PQfnumber(result, "detail"),
      hidden_fnum = PQfnumber(result, "hidden"),
      name_fnum = PQfnumber(result, "name"),
      timeout_fnum = PQfnumber(result, "timeout");
  if ((id_fnum | file_name_fnum | detail_fnum | name_fnum | timeout_fnum) < 0) {
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
      PQexecParams(conn_, TEST_SUITES_FIND_QUERY, 1, nullptr, param_values,
                   param_lengths, param_formats, 1);
  if (result == PGRES_TUPLES_OK && PQntuples(result) == 1) {
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
      PQexecParams(conn_, TEST_SUITES_QUERY, 1, nullptr, param_values,
                   param_lengths, param_formats, 1);
  int num_tuples = PQntuples(result);
  if(result == PGRES_TUPLES_OK && num_tuples > 0) {
    std::size_t vec_offset = suites.size() - 1;
    suites.resize(vec_offset + num_tuples + 1 );
    for(int tuple_index = 0; tuple_index < num_tuples ; tuple_index++) {
      parse(suites[tuple_index + vec_offset], result, tuple_index);
    }
    return true;
  } else {
    return false;
  }
}

}  // namespace evworker::db
