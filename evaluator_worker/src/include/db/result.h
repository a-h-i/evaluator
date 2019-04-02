#pragma once
#include <cstdint>
#include <string>
#include "json.hpp"
namespace evworker::db {
struct result_t {
  std::uint64_t id, submission_id, project_id, test_suite_id, submitter_id;
  nlohmann::json detail;
  std::string name;
  unsigned int max_grade, grade;
  bool hidden, success;
};
}  // namespace evworker::db