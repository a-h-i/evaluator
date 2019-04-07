#include <chrono>
#include "json.hpp"
#include "messaging/message.h"
#include "messaging/types.h"

namespace evworker::routing {

static void add_timestamp(nlohmann::json &message) {
  auto now = std::chrono::system_clock::now();
  message[message_fields::TIMESTAMP] =
      std::chrono::time_point_cast<std::chrono::seconds>(now)
          .time_since_epoch()
          .count();
}

std::string generate_worker_up_message(const std::string &worker_name,
                                       const std::string &pending_queue_name,
                                       const std::string &running_queue_name,
                                       const std::string &error_queue_name) {
  nlohmann::json message = {
      {message_fields::MESSAGE_TYPE, MessageType::WORKER_UP},
      {message_fields::WORKER_TASKS_PENDING_QUEUE_NAME, pending_queue_name},
      {message_fields::WORKER_TASKS_RUNNING_QUEUE_NAME, running_queue_name},
      {message_fields::WORKER_TASKS_ERROR_QUEUE_NAME, error_queue_name},
      {message_fields::WORKER_NAME, worker_name}};
  add_timestamp(message);
  return message.dump();
}

}  // namespace evworker::routing