#include "messaging/types.h"

namespace evworker::routing::message_fields {
  const std::string MESSAGE_TYPE = "TYPE";
  const std::string WORKER_TASKS_PENDING_QUEUE_NAME = "WPQN";
  const std::string WORKER_TASKS_RUNNING_QUEUE_NAME = "WRQN";
  const std::string WORKER_TASKS_ERROR_QUEUE_NAME = "WEQN";
  const std::string WORKER_NAME = "WN";
  const std::string TIMESTAMP = "TIMESTAMP";
}