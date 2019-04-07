#include "worker.h"
#include "options.h"
#include "worker_ctx.h"
#include "messaging/types.h"
#include <uuid/uuid.h>
#include <algorithm>
#include <cstring>
#include <exception>
#include <iostream>
#include <iterator>
#include <sstream>
#include <stdexcept>
#include "evspec/evspec.h"
#include "utils.h"

namespace evworker {

static void process_task(evworker_ctx_t *ctx, const routing::evaluation_message_t &message,
                         const std::string &worker_name) {
  // Fetch submission from DB
  db::submission_t submission;
  if (!ctx->find_submission(message.submission_id,
                            submission)) {
    // Submission is not in DB / could be old task. Report and end.
    throw std::runtime_error("[WORKER] " + worker_name + " processing " +
                             message.to_string() + " unable to find submission");
  }
  // Fetch testsuites from DB

  std::vector<db::test_suite_t> suites;
  if (!ctx->query_testsuites(submission.project_id, suites)) {
    throw std::runtime_error("[WORKER] " + worker_name + " processing " +
                             message.to_string() + " unable to find test suites");
  }
  // Fetch project from DB
  db::project_t project;

  if (!ctx->find_project(submission.project_id, project)) {
    throw std::runtime_error("[WORKER] " + worker_name + " processing " +
                             message.to_string() + " unable to find project");
  }
  // Grab files
  evspec::EvaluationContext evaluationContext;
  evaluationContext.specType = project.spec_type();
  evaluationContext.subtype = project.subtype();
  evaluationContext.srcPath = submission.get_path(ctx->config);
  std::transform(std::begin(suites), std::end(suites),
                 std::front_inserter(evaluationContext.suites),
                 [&project, ctx](const db::test_suite_t &suite) {
                   return suite.get_path(ctx->config);
                 });
  // Run Evaluation
  try {
    evspec::Result result =
        evspec::evaluateSubmission(&evaluationContext, ctx->virt_ctx());
    ctx->save_result(result, submission, suites);
  } catch (...) {
    std::throw_with_nested(std::runtime_error(
        std::string("process_task helper : error while running evaluation for "
                    "submission with id ") +
        std::to_string(submission.id)));
  }
}

static void evworker_ctx_t_deleter(void *ptr) {
  delete reinterpret_cast<evworker_ctx_t *>(ptr);
}
Worker::Worker(boost::program_options::variables_map const *vm)
    : ctx(new evworker_ctx_t(vm), evworker_ctx_t_deleter) {}

std::size_t Worker::process_queue() {
  evworker_ctx_t *evworkerCtxPtr =
      reinterpret_cast<evworker_ctx_t *>(ctx.get());
  std::forward_list<routing::evaluation_message_t> tasks;
  std::size_t num_tasks = evworkerCtxPtr->poll_tasks(tasks);
  for (auto &message : tasks) try {
      process_task(evworkerCtxPtr, message, worker_name());
      evworkerCtxPtr->pop_from_running();
    } catch (std::exception &e) {
      evworkerCtxPtr->shift_to_error(e.what());
      std::cerr << "[WORKER] " << worker_name()
                << " caught exception while processing queue\n"
                << e.what() << std::endl;
      utility::write_backtrace(STDERR_FILENO);
    }
  return num_tasks;
}

std::string Worker::worker_name() {
  return reinterpret_cast<evworker_ctx_t *>(ctx.get())->worker_id();
}
}  // namespace evworker