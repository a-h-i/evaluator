//
// ──────────────────────────────────────────────────── I ──────────
//   :::::: D A E M O N : :  :   :    :     :        :          :
// ──────────────────────────────────────────────────────────────
//

//
// ─── RUNS AND MANAGES WORKER PROCESSES
// ──────────────────────────────────────────
//

//
// ─── SPAWNS WORKER PROCESSES VIA VFORK
// ──────────────────────────────────────────
//

//
// ──────────
//

#include "evspec/process.h"
#include "globals.h"
#include "options.h"
#include "signal_handlers.h"
#include "utils.h"
#include <algorithm>
#include <cstdlib>
#include <cstring>
#include <filesystem>
#include <iostream>
#include <iterator>
#include <memory>
#include <sys/types.h>
#include <uuid/uuid.h>
#include <vector>

/**
 * @brief Process that manages subprocesses.
 *
 */
using namespace evworker;

template <typename Inserter>
void launch_workers(const char *uuid_cstr,
                    const std::filesystem::path &worker_exe_path,
                    const std::size_t NUM_WORKERS, options::variables_map &vm,
                    Inserter inserter) {
  evspec::process::ExecutionTarget et{
      .programPath{worker_exe_path.string()},
      .workingDirectory{std::filesystem::current_path().string()},
      .argv{{uuid_cstr},
            {options::CONFIG_PATH_SWITCH},
            {vm[options::CONFIG_PATH].as<std::string>()}},
      .env{}};

  std::generate_n(inserter, NUM_WORKERS,
                  std::bind(evspec::process::executeProcess, std::ref(et)));
}

int main(int argc, char const **argv) try {
  options::variables_map vm = options::parse_options(argc, argv);
  const std::filesystem::path worker_exe_path =
      vm[options::WORKER_EXE_PATH].as<options::worker_exe_path_t>();
  const std::size_t NUM_WORKERS =
      vm[options::NUM_WORKERS].as<options::num_workers_t>();
  evworker::children.reserve(NUM_WORKERS);
  // generate uuid
  uuid_t daemon_uuid;
  uuid_generate(daemon_uuid);
  char uuid_cstr[UUID_STR_LEN]{0};
  uuid_unparse_lower(daemon_uuid, uuid_cstr);
  //
  // ─── WRITE DAEMON PID
  // ──────────────────────────────────────────────────────────
  //

  auto pidRaii = utility::write_pid_file(
      std::filesystem::path(vm[options::PID_DIRECTORY].as<std::string>()),
      std::string(uuid_cstr), true);
  //
  // ─── LAUNCH WORKERS
  // ─────────────────────────────────────────────────────────────
  //

  launch_workers(uuid_cstr, worker_exe_path, NUM_WORKERS, vm,
                 std::back_inserter(evworker::children));
  std::atomic_signal_fence(std::memory_order_release);
  signals::is_daemon.store(true, std::memory_order_release);

  signals::install_daemon_signal_handlers();
  std::atomic_signal_fence(std::memory_order_relaxed);
  sigset_t suspend_signals;
  sigfillset(&suspend_signals);
  while (true) {
    // Sig USR1 or SIGTERM
    sigsuspend(&suspend_signals);
    if (signals::is_reload_state.load(std::memory_order_acquire)) {
      utility::kill_pids(children.begin(), children.end(), SIGTERM);
      evworker::utility::wait_all_children();
    } else if (signals::is_graceful_shutdown_state.load(
                   std::memory_order_acquire)) {
      utility::kill_pids(children.begin(), children.end(), SIGTERM);
      evworker::utility::wait_all_children();
      execv(argv[0], const_cast<char * const *>(argv));
      // 
      const char * errstr = strerror(errno);
      throw std::runtime_error(std::string("Failed to reaload daemon - ") + errstr);
    } else {
      throw std::runtime_error("sigsuspend returned and neither in graceful "
                               "shutdown state or reload state.");
    }
  }

  return 0;
} catch (const std::exception &e) {
  // print exception
  utility::print_exception(e);
  // print backtrace
  std::cerr << "Stack Backtrace:\n" << std::endl;
  utility::write_backtrace(STDERR_FILENO);
}
