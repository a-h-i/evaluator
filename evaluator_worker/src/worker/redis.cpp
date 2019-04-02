#include <exception>
#include <stdexcept>
#include "redis_ctx.h"
#include <algorithm>
#include <string>
#include <cstring>
#include <iterator>
//
// ─── WRAPPER FOR REDIS THAT INSURES RAII
// ────────────────────────────────────────
//

namespace evworker::redis {
redis_ctx::redis_ctx(const std::string &host, int port) noexcept(false) try {
  redis_ = redisConnect(host.c_str(), port);
  if (redis_ == nullptr || redis_->err) {
    std::string what = "unable to establish connection to redis - ";
    if (redis_) {
      what += redis_->errstr;

      freeRedis();
    }
    throw std::runtime_error("can not allocate redis context");
  }
  redisEnableKeepAlive(redis_);
} catch (...) {
  std::throw_with_nested(
      std::runtime_error("redis_ctx: constructor exception"));
}
redis_ctx::~redis_ctx() noexcept {
  freeRedis();
}

redis_ctx::redis_ctx(redis_ctx &&other) {
  std::swap(redis_, other.redis_);
}
redis_ctx &redis_ctx::operator=(redis_ctx &&other) {
  std::swap(redis_, other.redis_);
  return *this;
}
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

std::unique_ptr<char[]> reply_t::parse_reply() const {
  std::unique_ptr<char[]> buffer(new char[reply_->len + 1]);
  buffer[reply_->len] = 0; // ensure null terminated
  std::memcpy(buffer.get(), reply_->str, reply_->len);
  return buffer;
}

std::ostream &operator<<(std::ostream &out, const reply_t &reply) {
  std::copy_n(reply->str, reply->len, std::ostreambuf_iterator<char>(out));
  return out;
}

}  // namespace evworker::redis