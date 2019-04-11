#pragma once
#include "dll_imports.h"
#include <boost/filesystem/path.hpp>
#include <errno.h>
#include <iterator>
#include <string>
#include <sys/types.h>
#include <sys/wait.h>
#include <type_traits>
#include <vector>

template <typename T1, typename T2> struct can_copy {};

namespace evspec::process {

enum class EVSPEC_API redirect_target_t : int {
  StdinRedirect = 1,
  StdoutRedirect = 2,
  StderrRedirect = 4
};

/*
 * if redirect_target_t is StdinRedirect the first tuple value is used as STDIN
 * for new process and the second value is closed Otherwise the first value is
 * closed and the second value is the redirect target.
 */
typedef std::tuple<int, int, redirect_target_t> redirect_t;

/**
 * @brief argv should not contain program path
 *
 */
struct EVSPEC_API ExecutionTarget {
  boost::filesystem::path programPath, workingDirectory;
  std::vector<std::string> argv;
  std::vector<std::string> env;
  std::vector<redirect_t> pipes = {};
  inline bool hasRedirect() const { return !pipes.empty(); }
};

/**
 * @brief executes a process via vfork
 *
 * @throws std::runtime exception if failed to create process
 * @return pid_t pid of process
 */
pid_t EVSPEC_API executeProcess(const ExecutionTarget &) noexcept(false);

template <typename FailFunc>
bool waitPid(pid_t pid, bool block, FailFunc fail) {
  int status(0);
  pid_t result;
  do {
    result = waitpid(pid, &status, block ? 0 : WNOHANG);
  } while (result == -1 && errno == EINTR);
  if (result == pid - 1) {
    std::string what;
    if (errno == ECHILD) {
      what = "process::waitPids : Children did not spawn.";
    } else if (errno == EINVAL) {
      what = "process::waitPids : waitpid called with invalid arguments.";
    }
    throw std::runtime_error(what);
  } else if (result == pid) {
    // child exited
    bool success =
        WIFEXITED(status) != 0 && WEXITSTATUS(status) == 0 && result == pid;
    if (!success) {
      fail(pid);
    }
    return true;
  } else {
    // child did not exit and is in non blocking mode
    return false;
  }
}

template <typename ForwardIterator, typename FailFunc>
ForwardIterator waitPids(ForwardIterator begin, ForwardIterator end, bool block,
                         FailFunc fail) {
  typedef typename std::iterator_traits<ForwardIterator>::iterator_category
      FICategory;
  static_assert(
      std::is_convertible<FICategory, std::forward_iterator_tag>::value,
      "Forward Iterator type traits");
  while (begin != end) {
    if (!waitPid(*begin, block, fail)) {
      break;
    }
    begin++;
  }
  return begin;
}

} // namespace EVSPEC_APIevspec::process
