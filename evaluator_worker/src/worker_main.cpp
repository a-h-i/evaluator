#include "options.h"
#include "signal_handlers.h"
#include "utils.h"
#include "worker.h"
#include <atomic>
#include <errno.h>
#include <exception>
#include <iostream>
#include <unistd.h>
#include <chrono>
using namespace evworker;
int main(int argc, const char **argv) try {
  signals::install_worker_signal_handlers();
  options::variables_map vm = options::parse_options(argc, argv);
  evworker::Worker worker(vm);
  bool terminate;
  std::chrono::duration<double, std::milli> elapsed;
  do {
    auto start = std::chrono::high_resolution_clock::now();
    std::size_t num_tasks = worker.process_queue();
    auto end = std::chrono::high_resolution_clock::now();
    elapsed = end-start;
    std::cout << "Processed : " << num_tasks << " submissions in " << elapsed.count() << "ms\n";
    terminate =
        signals::is_graceful_shutdown_state.load(std::memory_order_acquire) | signals::is_reload_state.load(std::memory_order_acquire);
  } while (!terminate);
  return 0;
} catch (const std::exception &e) {
  // print exception
  utility::print_exception(e);
  // print backtrace
  std::cerr << "Stack Backtrace:\n" << std::endl;
  utility::write_backtrace(STDERR_FILENO);
}
