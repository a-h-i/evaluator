#pragma once
#include <atomic>


namespace evworker::signals {
  extern std::atomic_bool is_daemon, is_reload_state, is_graceful_shutdown_state;
  void install_daemon_signal_handlers();
  void install_worker_signal_handlers();
}