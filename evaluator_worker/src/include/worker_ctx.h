#pragma once
#include <forward_list>
#include <string>
#include "boost/program_options/variables_map.hpp"
#include "evspec/evspec.h"
#include "json.hpp"
#include "pg_ctx.h"
#include "redis_ctx.h"
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
  evworker_ctx_t(boost::program_options::variables_map const &vm) noexcept(
      false);
  bool check_redis_error(redisReply *reply, std::string *what);
  void throw_if_redis_error(redisReply *reply);
  std::size_t poll_tasks(std::forward_list<nlohmann::json> &tasks);
  void find_submission(std::uint64_t id, db::submission_t &submission);
  void query_testsuites(std::uint64_t project_id,
                        std::vector<db::test_suite_t> suites &);
  void pop_from_running();
  void shift_to_error(const std::string &);
  inline evspec::VirtualizationContext *virt_ctx() const { return virtCtxt; }
  
  ~evworker_ctx_t();
};

}  // namespace evworker