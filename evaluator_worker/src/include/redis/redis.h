#pragma once
#include "hiredis/hiredis.h"
#include <string>
#include <vector>
#include <ostream>


namespace evworker::redis {

class reply_t {
  redisReply *reply_{nullptr};

 public:
  inline reply_t(redisReply *reply) noexcept : reply_(reply) {}
  inline reply_t(reply_t &&other) noexcept {
    std::swap(reply_, other.reply_);
  }
  inline reply_t(const reply_t &) = delete;
  inline reply_t &operator=(const reply_t &) = delete;
  inline reply_t &operator=(reply_t &&other) noexcept {
    std::swap(reply_, other.reply_);
    return *this;
  }
  inline operator redisReply *() const { return reply_; }
  inline redisReply *operator->() const { return reply_; }
  inline ~reply_t() {
    if (reply_) {
      freeReplyObject(reply_);
      reply_ = nullptr;
    }
  }
  /**
   * @brief Returns true if null reply
   * 
   * @param what nullptr allowed
   * @return true 
   * @return false 
   */
  bool is_error_reply(std::string *what) const;
  /**
   * @brief Undefined behavior if called on error reply or null reply
   * 
   * @return std::vector<char> 
   */
  std::vector<char> parse_reply() const;
  void parse_reply(char *out) const;
  inline int reply_len() const {return reply_->len;} 
  inline bool is_string_reply() const {
    return reply_->type == REDIS_REPLY_STRING;
  }
  friend std::ostream &operator<<(std::ostream &out, const reply_t &reply);
};



// ──────────────────────────────────────────────────────────────────────────────────────────────────────────────
// I ──────────
//   :::::: S I M P L E   P R O X Y   C L A S S   F O R   R E D I S C O N T E X
//   T : :  :   :    :     :        :          :
// ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
//
class redis_ctx {
  redisContext *redis_{nullptr};
  inline void freeRedis() noexcept {
    if (redis_) {
      redisFree(redis_);
      redis_ = nullptr;
    }
  }

 public:
  redis_ctx() {}
  redis_ctx(const std::string &host, int port) noexcept(false);
  redis_ctx(redis_ctx &&);
  ~redis_ctx() noexcept;
  redis_ctx &operator=(const redis_ctx &) = delete;
  redis_ctx &operator=(redis_ctx &&);
  inline redisContext *operator->() const { return redis_; }
  inline operator redisContext *() const { return redis_; }
  template <typename... Args>
  reply_t command(Args... args) {
    return reinterpret_cast<redisReply *>(redisCommand(redis_, args...));
  }
};
}