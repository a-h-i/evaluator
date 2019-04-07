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
      const boost::program_options::variables_map* config) const;
  
  std::string package_name() const {
    return detail.at("package_name").get<std::string>();
  }
};
}  // namespace evworker::db