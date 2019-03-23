#pragma once
#include <cstdint>
#include <memory>
#include <string>
#include <vector>
#include "libpq-fe.h"
#include "records.h"

namespace evworker::db {
using records::result_t;
using records::submission_t;
using records::test_suite_t;
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
  PGresult *operator->() const { return result_; }
  bool operator==(ExecStatusType status) {
    if(nullptr) {
      return (status == PGRES_FATAL_ERROR) | false;
    }
    return PQresultStatus(result_) == status;
  }
  bool operator!=(ExecStatusType status) {
    return ! (*this == status);
  }
  operator PGresult *() const { return result_; }
  ~pg_result_t() {
    if (result_) {
      PQclear(result_);
      result_ = nullptr;
    }
  }
};

class pg_ctx {
  PGconn *conn_{nullptr};
  inline void freeConn() noexcept {
    if (conn_) {
      PQfinish(conn_);
      conn_ = nullptr;
    }
  }
 public:
  pg_ctx() {}
  pg_ctx(const std::string &host, int port, const std::string &db,
         const std::string &user, const std::string &password);
  inline pg_ctx(pg_ctx &&other) { std::swap(conn_, other.conn_); }
  pg_ctx(const pg_ctx &) = delete;
  pg_ctx &operator=(const pg_ctx &) = delete;
  inline pg_ctx &operator=(pg_ctx &&other) {
    std::swap(conn_, other.conn_);
    return *this;
  }
  operator bool() const;
  operator PGconn *() const {
    return conn_;
  }
  PGconn * operator->() const {
    return conn_;
  }
  void parse(submission_t &, pg_result_t &, int tuple_index = 0);
  void parse(test_suite_t &, pg_result_t &, int tuple_index = 0);
  bool find_submission(std::uint64_t id, submission_t &);
  bool find_testsuites(std::uint64_t project_id, std::vector<test_suite_t> &);
  bool find_testsuite(std::uint64_t id, test_suite_t &);
  ~pg_ctx() noexcept { freeConn(); }
};
}  // namespace evworker::db