#include "db/helpers.h"
#include "db/types.h"

namespace evworker::db {

const char *project_t::spec_type_attr{"spec_type"};
const char *project_t::spec_subtype_attr{"spec_subtype"};
}  // namespace evworker::db

static const char *PROJECT_FIND_QUERY = R"SQL(
  SELECT id, detail FROM projects WHERE id = $1::int8 LIMIT 1
)SQL";

namespace evworker::db {
void pg_ctx::parse(project_t &project, pg_result_t &result, int tuple_index) {
  int id_fnum, detail_fnum;
  id_fnum = PQfnumber(result, "id");
  detail_fnum = PQfnumber(result, "detail");
  if ((id_fnum | detail_fnum) < 0) {
    throw std::runtime_error(
        "pg_ctx::parse result : unable to get field numbers");
  }
  binary_from_column(project.id, result, tuple_index, id_fnum);
  json_from_column(project.detail, result, tuple_index, detail_fnum);
}
bool pg_ctx::find_project(std::uint64_t project_id, project_t &project) {
  std::uint64_t id_network_order = native_to_big(project_id);
  char *param_values[]{(char *)&id_network_order};
  int param_lengths[]{sizeof(id_network_order)};
  int params_format[]{1};
  pg_result_t result =
      PQexecParams(conn_, PROJECT_FIND_QUERY, 1, nullptr, param_values,
                   param_lengths, params_format, 1);
  if ((result == PGRES_TUPLES_OK) && (PQntuples(result) == 1)) {
    parse(project, result);
    return true;
  } else {
    return false;
  }
}
}  // namespace evworker::db