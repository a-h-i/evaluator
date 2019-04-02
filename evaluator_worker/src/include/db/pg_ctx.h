#pragma once
#include <vector>
#include "evspec/evspec.h"
#include "pg_result.h"
#include "submission.h"
#include "test_suite.h"
#include "project.h"
namespace evworker::db {
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
  operator PGconn *() const { return conn_; }
  PGconn *operator->() const { return conn_; }
  void parse(submission_t &, pg_result_t &, int tuple_index = 0);
  void parse(test_suite_t &, pg_result_t &, int tuple_index = 0);
  void parse(project_t &, pg_result_t &, int tuple_index = 0);
  bool find_submission(std::uint64_t id, submission_t &);
  bool find_testsuites(std::uint64_t project_id, std::vector<test_suite_t> &);
  bool find_testsuite(std::uint64_t id, test_suite_t &);
  bool find_project(std::uint64_t id, project_t &);
  void save_result(const evspec::Result &result,
                   const db::submission_t &submission,
                   const std::vector<db::test_suite_t> &suites);
  ~pg_ctx() noexcept { freeConn(); }
};
}  // namespace evworker::db