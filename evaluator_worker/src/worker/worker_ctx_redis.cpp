#include "json.hpp"
#include "message_types.h"
#include "worker_ctx.h"
#include <memory>
#include <iostream>
#include "utils.h"

//
// ──────────────────────────────────────────────────────────────────────────────────────────────
// V ──────────
//   :::::: R E D I S   R E L A T E D   F U N C T I O N A L I T Y : :  :   : :
//   :        :          :
// ────────────────────────────────────────────────────────────────────────────────────────────────────────
//

namespace evworker {

constexpr unsigned int QUEUE_POLL_TIMEOUT = 10u;


void evworker_ctx_t::notify_mq_server_ready() {
  // send msg to ctrl queue
  nlohmann::json message = {
      {MetaFieldType::MESSAGE_TYPE, MessageType::WORKER_UP},
      {MetaFieldType::WORKER_TASKS_PENDING_QUEUE_NAME,
       redis_pending_task_queue_name},
      {MetaFieldType::WORKER_TASKS_RUNNING_QUEUE_NAME,
       redis_running_task_queue_name},
      {MetaFieldType::WORKER_TASKS_ERROR_QUEUE_NAME,
       redis_error_task_queue_name},
      {MetaFieldType::WORKER_NAME, worker_name}};

  std::string serialized = message.dump();
  redis::reply_t reply = redis.command("LPUSH %s", serialized.c_str());
  throw_if_redis_error(reply);
}


std::size_t evworker_ctx_t::poll_tasks(std::forward_list<nlohmann::json> &tasks) {
  std::size_t len = 0;
  do {
  redis::reply_t reply = redis.command("BRPOPLPUSH %s %s %i", redis_pending_task_queue_name.c_str(), 
  redis_running_task_queue_name.c_str(), QUEUE_POLL_TIMEOUT);
  throw_if_redis_error(reply);
  if(reply->type == REDIS_REPLY_NIL) {
    // timedout
    break;
  }
  if(!reply.is_string_reply()) {
    throw std::runtime_error("evworker_ctx_t::poll_tasks : unknown redis reply type");
  }
    std::unique_ptr<char[]> buff = reply.parse_reply();
    tasks.emplace_front(nlohmann::json::parse(buff.get()));
  } while( ++len < 5 );
  return len;
}

void evworker_ctx_t::pop_from_running() {
  throw_if_redis_error(redis.command("RPOP %s", redis_running_task_queue_name.c_str()));
}

void evworker_ctx_t::shift_to_error(const std::string &error) {
  redis::reply_t reply = redis.command("RPOPLPUSH %s %s", redis_running_task_queue_name.c_str(), redis_error_task_queue_name.c_str());
  std::cerr << "evworker_ctx_t::shift_to_error called\n" << "exception " << error << "\nbacktrace:" << std::endl;
  utility::write_backtrace(STDERR_FILENO);
  std::string what;
  if(reply.is_error_reply(&what)) {
    std::cerr << "\nEncountered redis error while processing error. - " << what << '\n';
  }
  if(!reply.is_string_reply()) {
    std::cerr << "\nUnable to retrieve message from reply.\n";
    return;
  }
  std::cerr << "\nmessage being processed\n" << reply << '\n';
}
}  // namespace evworker