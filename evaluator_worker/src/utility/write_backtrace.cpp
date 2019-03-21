#include "utils.h"
#include <array>
#include <execinfo.h>

static std::array<void *, evworker::utility::STACKTRACE_SIZE> backtrace_buffer;

void evworker::utility::write_backtrace(int fd) {
  std::size_t backtrace_size =
      backtrace(backtrace_buffer.begin(), backtrace_buffer.max_size());
  backtrace_symbols_fd(backtrace_buffer.cbegin(), backtrace_size, fd);
}