#include <exception>
#include <stdexcept>
#include "redis_ctx.h"

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
}  // namespace evworker::redis