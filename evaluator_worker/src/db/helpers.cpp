#include "db/helpers.h"

namespace evworker::db {
  std::string text_from_column(pg_result_t &result, int tuple_index,
                                    int field_index) {
  if (PQgetisnull(result, tuple_index, field_index) == 1) {
    return std::string();
  } else {
    
    return std::string((char *)PQgetvalue(result, tuple_index, field_index));
  }
}
void json_from_column(json &j, pg_result_t &result, int tuple_index,
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
}