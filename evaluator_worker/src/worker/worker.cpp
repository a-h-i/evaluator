#include "worker.h"
#include "evspec/evspec.h"
#include "hiredis/hiredis.h"
#include "libpq-fe.h"
struct evworker_ctx_t {
  redisContext *redis;
  PGconn *conn;
  evspec::LibXmlRaii libxmlraii;
  evworker_ctx_t(boost::program_options::variables_map const &vm) {

  }
  ~evworker_ctx_t() {
    PQfinish(conn);
    redisFree(redis);
  }
};

static void evworker_ctx_t_deleter(void *ptr) {
  delete reinterpret_cast<evworker_ctx_t *> (ptr);
}

namespace evworker {
  Worker::Worker(boost::program_options::variables_map const &vm) : ctx(new evworker_ctx_t(vm), evworker_ctx_t_deleter){

  }
  Worker::~Worker() {

  }

  std::size_t Worker::process_queue() {

  }
}