#include <algorithm>
#include <cstring>
#include <exception>
#include <iterator>
#include <sstream>
#include <string>
#include <type_traits>
#include "uuid/uuid.h"
#include "worker_ctx.h"

//
// ──────────────────────────────────────────────────────────────────────────────────────────────────────
// IV ──────────
//   :::::: R A I I   S E M A N T I C S   F O R   E V W O R K E R   C T X : :  :
//   :    :     :        :          :
// ────────────────────────────────────────────────────────────────────────────────────────────────────────────────
//

namespace evworker {

evworker_ctx_t::evworker_ctx_t(
    boost::program_options::variables_map const &vm) noexcept(false) try {
  //
  // ─── SETUP REDIS
  // ────────────────────────────────────────────────────────────────
  //

  const std::string redis_host =
      vm[options::REDIS_HOST].as<options::redis_host_t>();
  const int redis_port = vm[options::REDIS_PORT].as<options::redis_port_t>();
  const int redis_db = vm[options::REDIS_DB].as<options::redis_db_t>();
  redis = {redis_host, redis_port};
  if (vm.count(options::REDIS_AUTH)) {
    // conditional authentication
    const std::string redis_auth =
        vm[options::REDIS_AUTH].as<options::redis_auth_t>();
    redis::reply_t reply = redis.command("AUTH %s", redis_auth.data());
    throw_if_redis_error(reply);
  }
  // Select redis DB
  redis::reply_t reply = redis.command("SELECT %d", redis_db);
  throw_if_redis_error(reply);
  redis_ctrl_queue_name =
      vm[options::REDIS_CTRL_QUEUE].as<options::redis_ctrl_queue_t>();

  std::string parent_uuid =
      vm[options::PARENT_UUID].as<options::parent_uuid_t>();
  using uuid_element_t = std::remove_all_extents<uuid_t>::type;
  uuid_element_t worker_uuid[sizeof(uuid_t) * 2]{0};
  uuid_parse(parent_uuid.data(), worker_uuid);
  uuid_t worker_uuid_fragment;
  uuid_generate(worker_uuid_fragment);
  memcpy(worker_uuid + sizeof(uuid_t), worker_uuid_fragment, sizeof(uuid_t));
  std::ostringstream ostream;
  ostream << std::hex;
  std::copy_n(worker_uuid, sizeof(worker_uuid),
              std::ostream_iterator<uuid_element_t>(ostream));
  worker_name = ostream.str();
  redis_pending_task_queue_name = worker_name + "-pending";
  redis_running_task_queue_name = worker_name + "-running";
  redis_error_task_queue_name = worker_name + "-error";

  //
  // ─── SETUP POSTGRESQL
  // ───────────────────────────────────────────────────────────
  //
  pg = {vm[options::DB_HOST].as<std::string>(),
        vm[options::DB_PORT].as<options::db_port_t>(),
        vm[options::DB_NAME].as<std::string>(),
        vm[options::DB_USER].as<std::string>(),
        vm[options::DB_PASS].as<std::string>()};

  //
  // ─── NOTIFY MESSAGING SERVER THAT WORKER IS READY AND REGISTER AS A WORKER
  // ───────────────────────────────
  //
  notify_mq_server_ready();
} catch (...) {
  std::throw_with_nested(
      std::runtime_error("evworker_ctx_t - constructor error"));
}

evworker_ctx_t::~evworker_ctx_t() {
  if (pg != nullptr) {
    PQfinish(pg);
  }
}

}  // namespace evworker
