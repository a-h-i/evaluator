#include "worker.h"
#include "options.h"
#include "worker_ctx.h"

#include <algorithm>
#include <cstring>
#include <exception>
#include <stdexcept>
#include <iterator>
#include <sstream>
#include <uuid/uuid.h>
#include "evspec/evspec.h"

namespace evworker {

static void process_task(evworker_ctx_t *ctx, const nlohmann::json &message) {

// Fetch submission from DB
  db::submission_t submission;
  ctx->find_submission(message["submission_id"], submission);
// Fetch testsuites from DB

  std::vector<db::test_suite_t> suites;
  ctx->query_testsuites(submission.project_id, suites);
// Fetch project from DB
  db::project_t project;
  ctx->query_project(submission.project_id, project);
// Grab files
  evspec::EvaluationContext evaluationContext;
  evaluationContext.specType = project.spec_type();
  evaluationContext.subtype = project.subtype();
  evaluationContext.srcPath = submission.src_path();
  std::transform(std::begin(suites), std::end(suites), std::front_inserter(evaluationContext.suites), 
  [] (const db::test_suite_t &suite) {
    return suite.get_path();
  });
  
// Run Evaluation
  try {

    evspec::Result result = evspec::evaluateSubmission(&evaluationContext, ctx->virt_ctx());
    ctx->save_result(result, submission, suites);
  } catch(...) {
    std::throw_with_nested(std::runtime_error(std::string("process_task helper : error while running evaluation for submission with id ") + submission.id ));
  }
}

static void evworker_ctx_t_deleter(void *ptr) {
  delete reinterpret_cast<evworker_ctx_t *>(ptr);
}
Worker::Worker(boost::program_options::variables_map const &vm)
    : ctx(new evworker_ctx_t(vm), evworker_ctx_t_deleter) {}

std::size_t Worker::process_queue() {
  evworker_ctx_t * evworkerCtxPtr = reinterpret_cast<evworker_ctx_t *>(ctx.get());
  std::forward_list<nlohmann::json> tasks;
  std::size_t num_tasks = evworkerCtxPtr->poll_tasks(tasks);
// TODO: Implement
for(auto &message : tasks) try {
  process_task(evworkerCtxPtr, message);
  evworkerCtxPtr->pop_from_running();
} catch (std::exception &e) {
  evworkerCtxPtr->shift_to_error(e.what());
} 
  return num_tasks;
}
} // namespace evworker