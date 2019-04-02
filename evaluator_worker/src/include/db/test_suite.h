#pragma once
#include <cstdint>
#include <string>
#include "boost/filesystem/path.hpp"
#include "boost/program_options/variables_map.hpp"
#include "json.hpp"

namespace evworker::db {
struct test_suite_t {
  std::uint64_t id, project_id;
  std::string file_name, name;
  nlohmann::json detail;
  int timeout;
  bool hidden;
  boost::filesystem::path get_path(
      std::uint64_t project_id,
      const boost::program_options::variables_map* config) const;
};
}  // namespace evworker::db