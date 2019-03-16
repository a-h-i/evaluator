#include "process.h"
#include <boost/filesystem.hpp>
#include <cstdlib>
#include <cstring>
#include <errno.h>
#include <stdexcept>
#include <unistd.h>
#include <utility>
#include <fcntl.h>

namespace fs = boost::filesystem;
[[noreturn]] static void handleForkError(int error) {
  std::string what("Error while forking at process::executeProcess: ");
  switch (error) {
  case EAGAIN:
    // hit system limit
    what += "System limit reached";
    break;
  case ENOMEM:
    // No memory
    what += "Out of memory";
    break;
  case ENOSYS:
    // hardware does not support fork
    what += "System does not support fork/vfork";
    break;
  default:
    // unknown error
    what += "errorno = " + std::to_string(error);
  }
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
  switch (err)
  {
    case E2BIG:
      what += R"WHAT(
        The total number of bytes in the environment (envp) and
              argument list (argv) is too large.
      )WHAT";
      break;
    case EACCES:
      what += R"WHAT(
        Search permission is denied on a component of the path prefix
              of filename or the name of a script interpreter. 
        Or
        Execute permission is denied for the file or a script or ELF
              interpreter.
      )WHAT";
      break;
    case EFAULT:
      what += R"WHAT(
        filename or one of the pointers in the vectors argv or envp
              points outside your accessible address space.

      )WHAT";
      break;
    case EMFILE:
      what += R"WHAT(
    The per-process limit or system-wide limit on the number of open file descriptors
              has been reached.
      )WHAT";
      break;
    case ENOMEM:
      what += R"WHAT(
        Insufficient kernel memory was available.
      )WHAT";
      break;
    case ETXTBSY:
      what += R"WHAT(
        The specified executable was open for writing by one or more
              processes.
      )WHAT";
      break;
    default:
      what += "errorno = " + std::to_string(err);
  }
  throw std::runtime_error(what);
}

[[noreturn]] static void handleDupError(int err) {
  std::string what = "dup error process::executeProcess : ";
  switch(err) {
    case EBADF:
      what += "oldfd is not a valid file descriptor or newfd is out of the allowed range";
      break;
    case EBUSY:
      what += "EBUSY, race condition in open probable cause";
      break;
    case EINTR:
      what += "dup was interrupted";
      break;
    case EMFILE:
      what += "The per-process limit on the number of open file descriptors has been reached";
      break;
    default:
      what += "errorno = " + std::to_string(err);
  }
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
                      const std::vector<process::redirect_t> &pipes) {
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
        close(std::get<0>(redirect));
        int target = redirectType == process::redirect_target_t::StdoutRedirect ? STDOUT_FILENO : STDERR_FILENO;
        dupResult = dupLoop(std::get<1>(redirect), target);
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

pid_t process::executeProcess(const process::ExecutionTarget &target) noexcept(
    false) {
  fs::path prevWorkingDirectory = fs::current_path();
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