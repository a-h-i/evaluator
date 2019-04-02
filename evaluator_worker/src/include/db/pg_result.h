#pragma once
#include "libpq-fe.h"
#include <memory>

namespace evworker::db {
  class pg_result_t {
  PGresult *result_{nullptr};

 public:
  pg_result_t(PGresult *result) : result_(result) {}
  pg_result_t(const pg_result_t &) = delete;
  pg_result_t(pg_result_t &&other) { std::swap(result_, other.result_); }
  pg_result_t &operator=(const pg_result_t &) = delete;
  pg_result_t &operator=(pg_result_t &&other) {
    std::swap(result_, other.result_);
    return *this;
  }
  inline PGresult *operator->() const { return result_; }
  inline bool operator==(ExecStatusType status) {
    if(nullptr) {
      return (status == PGRES_FATAL_ERROR) | false;
    }
    return PQresultStatus(result_) == status;
  }
  inline bool operator!=(ExecStatusType status) {
    return ! (*this == status);
  }
  inline operator PGresult *() const { return result_; }
  ~pg_result_t() {
    if (result_) {
      PQclear(result_);
      result_ = nullptr;
    }
  }
};

}