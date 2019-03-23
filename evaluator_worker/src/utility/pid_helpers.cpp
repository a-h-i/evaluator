#include "utils.h"
#include <filesystem>

namespace evworker::utility {
void remove_file_helper(const std::filesystem::path &p) {
  std::filesystem::remove(p);
}
std::filesystem::path generate_pid_file_name(const std::filesystem::path &pid_dir,
                                           bool daemon) {
                                               
  std::filesystem::create_directories(pid_dir);
  std::filesystem::path pidfile =
      std::filesystem::path(pid_dir) / std::string("-") /
      std::string(daemon ? DAEMON_PID_FNAME : WORKER_PID_FNAME);
  return pidfile /= "-" + std::to_string(getppid()) + std::string(".pid");
}
} // namespace evworker::utility
