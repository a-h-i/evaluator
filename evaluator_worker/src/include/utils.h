#pragma once
#include <exception>
#include <filesystem>
#include <fstream>
#include <functional>
#include <string>
#include <sys/wait.h>
#include <unistd.h>
#include <csignal>

namespace evworker::utility {
void print_exception(const std::exception &, int level = 0);
constexpr std::size_t STACKTRACE_SIZE = 32;
/**
 * @brief Writes current backtrace up to STACKTRACE_SIZE frames.
 * This is function is AS-Unsafe but MT-Safe.
 * @params fd
 */
void write_backtrace(int);
extern char const *DAEMON_PID_FNAME;
extern char const *WORKER_PID_FNAME;

template <typename FuncType, FuncType *Func, typename FuncReturnType = void>
struct Raii {
  std::function<FuncReturnType(void)> bound;
  template <typename... Args>
  Raii(Args... args) : bound(std::bind(Func, args...)) {}
  ~Raii() { std::invoke(bound); }
};

void remove_file_helper(const std::filesystem::path &p);
std::filesystem::path
generate_pid_file_name(const std::filesystem::path &pid_dir, bool daemon);
inline decltype(auto) write_pid_file(const std::filesystem::path &pid_dir,
                                     const std::string &identifier,
                                     bool daemon) {

  std::filesystem::path pidfile = generate_pid_file_name(pid_dir, daemon);
  std::ofstream pid_ostream(pidfile, std::ios::out | std::ios::app);
  pid_ostream << identifier;
  return Raii<decltype(remove_file_helper), remove_file_helper>(pidfile);
}
/**
 * @brief Reenternt AS-Safe MT-Safe
 *
 */
inline __attribute__((always_inline)) void wait_all_children() {
  while (true) {
    pid_t rvalue = wait(nullptr);
    if (rvalue == -1 && errno == ECHILD) {
      return;
    }
  }
}
template<typename Itr>
void kill_pids(Itr begin, Itr end, int sig) {
  while (begin != end) {
    kill(*begin, sig);
    begin++;
  }
}

std::filesystem::path generate_pid_file_name(const std::filesystem::path &pid_dir,
                                           bool daemon);



} // namespace evworker::utility