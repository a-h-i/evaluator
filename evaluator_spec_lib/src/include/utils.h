#pragma once
#include <unistd.h>
#include <boost/filesystem.hpp>
#include <iostream>
#include <iterator>
#include "boost/iostreams/device/file_descriptor.hpp"
#include "boost/iostreams/stream.hpp"
#include "dll_imports.h"

namespace evspec::utility {
namespace io = boost::iostreams;

template <typename Cont>
void EVSPEC_API
removeDirectories(const typename std::remove_reference<Cont>::type &list,
                  bool rethrow = false) try {
  for (auto const &dir : list) {
    boost::filesystem::remove_all(dir);
  }
} catch (const std::exception &e) {
  if (rethrow) {
    throw e;
  } else {
    std::cerr << "evspec::Spec::~Spec: exception caught during destruction "
              << e.what() << std::endl;
  }
}

boost::filesystem::path EVSPEC_API createTempDirectory();

template <class Obj, class Func, Func f>
struct EVSPEC_API apply_wrapper_t {
  Obj obj_;
  apply_wrapper_t(Obj obj) : obj_(obj){};
  ~apply_wrapper_t() { f(obj_); }
};
template <typename Callable>
struct EVSPEC_API wrapper_t {
  Callable c;
  wrapper_t(Callable c) : c(c) {}
  ~wrapper_t() { c(); };
};
inline std::istream EVSPEC_API transform_fd_read(int fd) {
  io::stream_buffer<io::file_descriptor_source> stream_bufer(
      fd, io::never_close_handle);
  return std::istream(&stream_bufer);
}

inline std::ostream EVSPEC_API transform_fd_write(int fd) {
  io::stream_buffer<io::file_descriptor_source> stream_bufer(
      fd, io::never_close_handle);
  return std::ostream(&stream_bufer);
}
template <typename Out>
void EVSPEC_API read_fd(Out out, int fd, bool close_fd = false) {
  std::istream stream = transform_fd_read(fd);
  std::vector<char> buffer(PIPE_BUF);
  while (stream) {
    std::size_t read_count = stream.readsome(buffer.data(), buffer.size());
    std::copy_n(buffer.begin(), read_count, out);
  }
  if (close_fd) {
    close(fd);
  }
}

template <typename In>
void EVSPEC_API write_fd(In begin, In end, int fd, bool close_fd = false) {
  std::ostream stream = transform_fd_write(fd);
  std::copy(begin, end, std::ostreambuf_iterator<char>(stream));
  if (close_fd) {
    close(fd);
  }
}

}  // namespace evspec::utility