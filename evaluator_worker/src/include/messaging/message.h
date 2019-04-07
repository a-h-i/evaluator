#pragma once
#include <string>
#include "messaging/types.h"

namespace evworker::routing {

std::string generate_worker_up_message(const std::string &worker_name,
                                          const std::string &pending_queue_name,
                                          const std::string &running_queue_name,
                                          const std::string &error_queue_name);

evaluation_message_t parse_evaluation_message(const char *buff);
}
