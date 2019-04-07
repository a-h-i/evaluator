#include "messaging/message.h"
#include <cstdlib>

namespace evworker::routing {

  evaluation_message_t parse_evaluation_message(const char *buff) {
    return std::strtoull(buff, nullptr, 10);
  }
}