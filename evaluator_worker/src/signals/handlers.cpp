#include "signal_handlers.h"
#include "utils.h"
#include "globals.h"
#include <array>
#include <atomic>
#include <csignal>
#include <iostream>
#include <unistd.h>
std::vector<pid_t> evworker::children;

void terminate_handler() {
  const char buffer[]{
      "Exception handling error, std::terminate called.\nbacktrace\n"};
  write(STDERR_FILENO, buffer, sizeof(buffer));
  // we call an AS-Unsafe function but we immediately terminate after and thus
  // the risk is minimal.
  evworker::utility::write_backtrace(STDERR_FILENO);
  _Exit(EXIT_FAILURE);
}

extern "C" void sig_user_1_handler(int, siginfo_t *, void *) {
  evworker::signals::is_reload_state.store(true, std::memory_order_release);
}

extern "C" void sig_term_handler(int, siginfo_t *, void *) {
  evworker::signals::is_graceful_shutdown_state.store(
      true, std::memory_order_release);
}

extern "C" [[noreturn]] void sig_abrt_handler(int, siginfo_t *, void *) {
  if(evworker::signals::is_daemon.load(std::memory_order_acquire)) {
    // Send to all processes with same process group as self.
    evworker::utility::kill_pids(evworker::children.begin(), evworker::children.end(), SIGTERM);
  }
  std::atomic_signal_fence(std::memory_order_acquire);
  evworker::utility::wait_all_children();

  std::_Exit(EXIT_FAILURE);
}

extern "C" void sig_segv_handler(int signal, siginfo_t *, void *) {
  const char buffer[]{"SIGSEGV caught. Backtrace:\n"};
  write(STDERR_FILENO, buffer, sizeof(buffer));
  evworker::utility::write_backtrace(STDERR_FILENO);
  std::signal(signal, SIG_DFL);
  std::raise(signal);
}

static void at_exit_handler() {
  if (evworker::signals::is_daemon.load(std::memory_order_acquire)) {
    // Send to all processes with same process group as self.
    evworker::utility::kill_pids(evworker::children.begin(),
                                 evworker::children.end(), SIGTERM);
  }
  std::atomic_signal_fence(std::memory_order_acquire);
  evworker::utility::wait_all_children();
}

static void install_signal_handler(bool daemon) {
  std::set_terminate(terminate_handler);
  std::atexit(at_exit_handler);
  struct sigaction sa_segv;
  sa_segv.sa_sigaction = sig_abrt_handler;
  sigfillset(&sa_segv.sa_mask);
  sa_segv.sa_flags = SA_SIGINFO;
  sigaction(SIGSEGV, &sa_segv, nullptr);
  struct sigaction sa_abrt;
  sa_abrt.sa_sigaction = sig_abrt_handler;
  sigfillset(&sa_abrt.sa_mask);
  sa_abrt.sa_flags = SA_SIGINFO;
  sigaction(SIGABRT, &sa_abrt, nullptr);

  //
  // ─── GRACEFUL SHUTDOWN
  // ──────────────────────────────────────────────────────────
  //

  struct sigaction sa_term;
  sa_term.sa_sigaction = sig_term_handler;
  sigemptyset(&sa_term.sa_mask);
  sigaddset(&sa_term.sa_mask, SIGTERM);
  sigaddset(&sa_term.sa_mask, SIGKILL);
  sa_term.sa_flags = SA_SIGINFO;
  sigaction(SIGTERM, &sa_term, nullptr);
  sigaction(SIGQUIT, &sa_term, nullptr);

  //
  // ─── RELOAD CONFIGURATION AND CODE IF DAEMON ELSE IGNORE
  // ────────────────────────
  //

  struct sigaction sa_usr1;
  if (daemon) {
    sa_usr1.sa_sigaction = sig_user_1_handler;

    sigemptyset(&sa_usr1.sa_mask);
    sa_usr1.sa_flags = SA_SIGINFO | SA_NODEFER;
  } else {
    sa_usr1.sa_handler = SIG_IGN;
  }
  sigaction(SIGUSR1, &sa_usr1, nullptr);

  //
  // ─── IGNORED SIGNALS ────────────────────────────────────────────────────────────
  //

  std::signal(SIGHUP, SIG_IGN);
  std::signal(SIGCHLD, SIG_IGN);

    
}

void evworker::signals::install_daemon_signal_handlers() {
  install_signal_handler(true);
}

void evworker::signals::install_worker_signal_handlers() {
  install_signal_handler(false);
}