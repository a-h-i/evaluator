#pragma once
#include <string>

namespace evworker::routing {


namespace message_fields {
  extern const std::string MESSAGE_TYPE;
  extern const std::string WORKER_TASKS_PENDING_QUEUE_NAME;
  extern const std::string WORKER_TASKS_RUNNING_QUEUE_NAME;
  extern const std::string WORKER_TASKS_ERROR_QUEUE_NAME;
  extern const std::string WORKER_NAME;
  extern const std::string TIMESTAMP;
}

enum class MessageType: unsigned int {
  WORKER_UP = 1
};


struct evaluation_message_t {
  std::uint64_t submission_id;
  evaluation_message_t(std::uint64_t id) : submission_id(id) {}
  inline std::string to_string() const {
    return std::string("evaluation message for submission : ") + std::to_string(submission_id);
  }
};

}


