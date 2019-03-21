#include "signal_handlers.h"
#include <atomic>

namespace evworker::signals {
std::atomic_bool is_daemon(false), is_reload_state(false),
    is_graceful_shutdown_state(false);
}