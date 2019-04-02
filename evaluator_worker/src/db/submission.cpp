#include <string>
#include "db/helpers.h"
#include "db/types.h"
#include "options.h"

namespace evworker::db {

fs::path submission_t::get_path(
    const boost::program_options::variables_map *config) const {
  fs::path path(config->at(options::SUBMISSION_BASE_PATH).as<std::string>());
  path /= std::to_string(id) + formatted_created_at;
  path += fs::path(file_name).extension();
  return path;
}
}  // namespace evworker::db
static const char *SUBMISSION_FIND_QUERY = R"SQL(
  SELECT id, project_id, submitter_id, file_name, team, to_char(created_at, 'YYYY_DDD_HH24_MI_SS_MS') AS created_at_formatted FROM submissions WHERE id = $1::int8 LIMIT 1
)SQL";
namespace evworker::db {
void pg_ctx::parse(submission_t &submission, pg_result_t &result,
                   int tuple_index) {
  int id_fnum, project_id_fnum, submitter_id_fnum, file_name_fnum, team_fnum,
      created_at_formatted_fnum;
  id_fnum = PQfnumber(result, "id");
  project_id_fnum = PQfnumber(result, "project_id");
  submitter_id_fnum = PQfnumber(result, "submitter_id");
  file_name_fnum = PQfnumber(result, "file_name");
  team_fnum = PQfnumber(result, "team");
  created_at_formatted_fnum = PQfnumber(result, "created_at_formatted");
  if ((id_fnum | submitter_id_fnum | project_id_fnum | file_name_fnum |
       created_at_formatted_fnum | team_fnum) < 0) {
    throw std::runtime_error(
        "pg_ctx::parse submission : unable to get field numbers");
  }

  binary_from_column(submission.id, result, tuple_index, id_fnum);
  binary_from_column(submission.project_id, result, tuple_index,
                     project_id_fnum);
  binary_from_column(submission.submitter_id, result, tuple_index,
                     submitter_id_fnum);

  submission.file_name = text_from_column(result, tuple_index, file_name_fnum);
  submission.team = text_from_column(result, tuple_index, team_fnum);
  submission.formatted_created_at =
      text_from_column(result, tuple_index, created_at_formatted_fnum);
}

bool pg_ctx::find_submission(std::uint64_t id, submission_t &submission) {
  std::uint64_t id_network_order = native_to_big(id);
  char *param_values[]{(char *)&id_network_order};
  int param_lengths[]{sizeof(id_network_order)};
  int param_formats[]{1};

  pg_result_t result =
      PQexecParams(conn_, SUBMISSION_FIND_QUERY, 1, nullptr, param_values,
                   param_lengths, param_formats, 1);
  if ((result == PGRES_TUPLES_OK) && (PQntuples(result) == 1)) {
    parse(submission, result);
    return true;

  } else {
    return false;
  }
}
}  // namespace evworker::db