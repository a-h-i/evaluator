#pragma once
#include <cstdint>
#include <string>
#include "boost/filesystem/path.hpp"
#include "boost/program_options/variables_map.hpp"

namespace evworker::db {
struct submission_t {
  std::uint64_t id, project_id, submitter_id;
  std::string file_name, team, formatted_created_at;
  boost::filesystem::path get_path(
      const boost::program_options::variables_map *config) const;
};
}  // namespace evworker::db