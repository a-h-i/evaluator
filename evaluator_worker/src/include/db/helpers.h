#pragma once
#include <boost/endian/conversion.hpp>
#include "libpq-fe.h"
#include "db/types.h"
#include "json.hpp"
#include <string>
namespace evworker::db {
using nlohmann::json;

using boost::endian::big_to_native;
using boost::endian::big_to_native_inplace;
using boost::endian::native_to_big;
using boost::endian::native_to_big_inplace;

template <typename Numeric>
void binary_from_column(Numeric &dest, pg_result_t &result, int tuple_index,
                        int field_index) {
  dest = big_to_native(*reinterpret_cast<Numeric *>(
      PQgetvalue(result, tuple_index, field_index)));
}
std::string text_from_column(pg_result_t &result, int tuple_index,
                                    int field_index);
void json_from_column(json &j, pg_result_t &result, int tuple_index,
                             int field_index);                                  
}  // namespace evworker::db