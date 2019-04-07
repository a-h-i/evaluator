#pragma once
#include <forward_list>
#include <string>
#include <vector>
#include "boost/program_options/variables_map.hpp"
#include "db/types.h"
#include "evspec/evspec.h"
#include "json.hpp"
#include "messaging/types.h"
#include "redis/redis.h"
#include "worker.h"
namespace evworker {

using db::pg_ctx;
using redis::redis_ctx;

//
// ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
// V ──────────
//   :::::: H E L P E R   C L A S S   F O R   W O R K E R   S T A T E   A N D I
//   N T E R A C T I N G   W I T H   R E D I S   A N D   P O S T G R E S : :  :
//   :    :     :        :          :
// ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
//
class evworker_ctx_t {
  redis_ctx redis;
  pg_ctx pg;
  evspec::VirtualizationContext *virtCtxt{nullptr};
  evspec::LibXmlRaii libxmlraii;
  std::string redis_pending_task_queue_name, redis_running_task_queue_name,
      redis_error_task_queue_name, redis_ctrl_queue_name, worker_name;
  void notify_mq_server_ready();

 public:
  const boost::program_options::variables_map *config;
  evworker_ctx_t(const boost::program_options::variables_map *vm) noexcept(
      false);

  inline void throw_if_redis_error(const redis::reply_t &reply) {
    std::string what;
    if (reply.is_error_reply(&what)) {
      throw std::runtime_error("evworker_ctx_t redis error : " + what);
    }
  }
  /**
   * @brief pops right most entry in pending task queue , pushes it from the left into running queue
   * atomically.
   * Parses retrieved tasks and places them in the back of tasks parameter.
   * @param tasks
   * @return std::size_t  number of tasks retrieved
   */
  std::size_t poll_tasks(
      std::forward_list<routing::evaluation_message_t> &tasks);
  inline bool find_submission(std::uint64_t id, db::submission_t &submission) {
    return pg.find_submission(id, submission);
  }
  inline bool query_testsuites(std::uint64_t project_id,
                               std::vector<db::test_suite_t> &suites) {
    return pg.find_testsuites(project_id, suites);
  }
  inline bool find_project(std::uint64_t project_id, db::project_t &project) {
    return pg.find_project(project_id, project);
  }
  /**
   * @brief Removes right most element from running task queue
   * 
   */
  void pop_from_running();
  /**
   * @brief Shifts right most element from running task queue to error queue
   * 
   */
  void shift_to_error(const std::string &);
  inline evspec::VirtualizationContext *virt_ctx() const { return virtCtxt; }
  inline std::string worker_id() { return worker_name; }
  inline void save_result(const evspec::Result &result,
                          const db::submission_t &submission,
                          const std::vector<db::test_suite_t> &suites) {
    pg.save_result(result, submission, suites);
  }
  ~evworker_ctx_t();
};

}  // namespace evworker