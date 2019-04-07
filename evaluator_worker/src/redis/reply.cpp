#include <algorithm>
#include <cstring>
#include "redis/redis.h"

namespace evworker::redis {
bool reply_t::is_error_reply(std::string *what) const {
  if (reply_ == nullptr) {
    // connection error
    return true;
  } else if (reply_->type == REDIS_REPLY_ERROR) {
    // server replied with an error reply
    if (what) {
      std::copy_n(reply_->str, reply_->len, std::back_inserter(*what));
    }
    return true;
  } else {
    // no error
    return false;
  }
}
std::vector<char> reply_t::parse_reply() const {
  std::vector<char> buffer(reply_len());
  parse_reply(buffer.data());
  return buffer;
}

void reply_t::parse_reply(char *out) const {
  std::memcpy(out, reply_->str, reply_->len);
}

std::ostream &operator<<(std::ostream &out, const reply_t &reply) {
  std::copy_n(reply->str, reply->len, std::ostreambuf_iterator<char>(out));
  return out;
}
}  // namespace evworker::redis