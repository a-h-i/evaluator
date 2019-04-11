#include "process.h"
#include <boost/filesystem.hpp>
#include <cstdlib>
#include <cstring>
#include <errno.h>
#include <stdexcept>
#include <unistd.h>
#include <utility>
#include <fcntl.h>
using namespace evspec;
namespace fs = boost::filesystem;
[[noreturn]] static void handleForkError(int error) {
  std::string what("Error while forking at process::executeProcess: ");
  char * errorstr = strerror(error);
  std::copy_n(errorstr, strlen(errorstr), std::back_inserter(what));
  throw std::runtime_error(what);
}
static pid_t executeWithVfork(std::vector<char *> &argv, std::vector<char *> &env,
                         const char *programPath) {
  pid_t pid = vfork();
  if (pid == 0) {
    // this is child process
    // Using vfork we are sharing all memory with parent including stack
    // it's not copy on write, it's share.
    // It is undefined behavior to do anything besides calling execve or calling
    // _exit
    if (execve(programPath, argv.data(), env.data()) == -1) {
      // child failed to exec
      std::_Exit(EXIT_FAILURE);
    }
  }
  // parent
  if (pid < 0) {
    // Error
    handleForkError(errno);

  } else {
    // this is parent process and everything is fine
    return pid;
  }
}

[[noreturn]] static void handleExecveError(int err) {
  std::string what = "execve error process::executeProcess : ";
  char *errorstr = strerror(err);
  std::copy_n(errorstr, strlen(errorstr), std::back_inserter(what));
  throw std::runtime_error(what);
}

[[noreturn]] static void handleDupError(int err) {
  std::string what = "dup error process::executeProcess : ";
  char *errorstr = strerror(err);
  std::copy_n(errorstr, strlen(errorstr), std::back_inserter(what));
  throw std::runtime_error(what);
}

inline int dupLoop(int oldfd, int newfd) {
  int result;
  do {
    result = dup2(oldfd, newfd);
  } while(result == -1 && errno == EINTR);
  return result;
}

static pid_t executeWithFork(std::vector<char *> &argv, std::vector<char *> &env,
                      const char *programPath,
                      const std::vector<evspec::process::redirect_t> &pipes) {
  pid_t pid = fork();
  if (pid == 0) {
    // child
    for (const process::redirect_t &redirect : pipes) {
      int dupResult = 0;
      process::redirect_target_t redirectType = std::get<2>(redirect);
      if (redirectType == process::redirect_target_t::StdinRedirect) {
        // stdin redirect
        close(std::get<1>(redirect));
        dupResult = dupLoop(std::get<0>(redirect), STDIN_FILENO);
      } else {
        // output redirect
        close(std::get<0>(redirect));
        // int target = redirectType == process::redirect_target_t::StdoutRedirect ? STDOUT_FILENO : STDERR_FILENO;
        // dupResult = dupLoop(std::get<1>(redirect), target);
      }
      if(dupResult < 0) {
        handleDupError(errno);
      }
    }
    if (execve(programPath, argv.data(), env.data()) == -1) {
      // child failed to exec
      handleExecveError(errno);
    }
  }
  // parent
  if (pid < 0) {
    // error
    handleForkError(errno);
  } else {
    // everything is fine!
    return pid;
  }
}

struct PathRai {
  PathRai(const fs::path &toRestore) : toRestore(toRestore) {}
  ~PathRai() {fs::current_path(toRestore);}
  const fs::path toRestore;
};

pid_t evspec::process::executeProcess(const process::ExecutionTarget &target) noexcept(
    false) {
  PathRai pathRai(fs::current_path()) ;
  fs::current_path(target.workingDirectory);
  const char *programPath = target.programPath.c_str();
  std::vector<char *> argv;
  argv.reserve(target.argv.size() + 2);
  std::vector<char *> env;
  env.reserve(target.env.size() + 2);
  for (const std::string &s : target.env) {
    env.push_back(const_cast<char *>(s.c_str()));
  }
  env.push_back(nullptr);
  argv.push_back(const_cast<char *>(programPath));
  for (const std::string &s : target.argv) {
    argv.push_back(const_cast<char *>(s.c_str()));
  }
  argv.push_back(nullptr);
  if (target.hasRedirect()) {
    return executeWithFork(argv, env, programPath, target.pipes);
  } else {
    // temporary redirect stdout
    fflush(stdout);
    int stdoutBackup = dup(STDOUT_FILENO);
    int nullStream = open("/dev/null", O_WRONLY);
    dup2(nullStream, STDOUT_FILENO);
    close(nullStream);
    pid_t pid = executeWithVfork(argv, env, programPath);
    // restore stdout
    dup2(stdoutBackup, STDOUT_FILENO);
    close(stdoutBackup);
    return pid;
  }
}