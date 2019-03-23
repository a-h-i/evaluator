#pragma once
#include <cstdint>
#include <string>
#include "json.hpp"

namespace evworker::records {
  using nlohmann::json;
  struct result_t {
    std::uint64_t id, submission_id, project_id, test_suite_id, submitter_id;
    json detail;
    std::string name;
    unsigned int max_grade, grade; 
    bool hidden, success;
  };

  struct submission_t {
    std::uint64_t id, project_id, submitter_id, created_at;
    std::string file_name, team;
  };

  struct test_suite_t {
    std::uint64_t id, project_id;
    json detail;
    std::string file_name, name;
    int timeout;
    bool hidden;
  };
}