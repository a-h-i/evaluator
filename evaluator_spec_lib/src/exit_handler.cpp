
#include <cstdlib>
#include <errno.h>
#include <evspec.h>
#include <sys/wait.h>


void exitHandler() {
  while (true) {
    pid_t rvalue = wait(nullptr);
    if (rvalue == -1 && errno == ECHILD) {
      return;
    }
  }
}

extern "C" [[noreturn]] void abortHandler([[maybe_unused]] int signal) {
  exitHandler(); // exit handler must be async signal safes
  std::_Exit(EXIT_FAILURE);
}

void (* const evspec::exitHandler)() = ::exitHandler;
void (* const evspec::abortHandler)(int) = ::abortHandler;