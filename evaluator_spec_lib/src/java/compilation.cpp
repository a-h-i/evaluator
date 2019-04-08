#include "internal/java.h"
#include "process.h"
#include <algorithm>
#include "boost/iostreams/device/file_descriptor.hpp"
#include "boost/iostreams/stream.hpp"
#include <exception>
#include <forward_list>
#include <iostream>
#include <limits.h>
#include <string>
#include <unistd.h>

evspec::Result evspec::java::compile(const fs::path &workingDirectory) {
  // setup pipes
  std::forward_list<pid_t> pidList;
  int srcCompilerPipe[2], testCompilerPipe[2];
  pipe(srcCompilerPipe);
  pipe(testCompilerPipe);

  // create execution targets
  process::ExecutionTarget compileSrcTarget = {
      .programPath = "/bin/env",
      .workingDirectory = workingDirectory,
      .argv = {std::string("mvn"), std::string("compile")},
      .env = {},
      .pipes = {{srcCompilerPipe[0], srcCompilerPipe[1],
                 process::redirect_target_t::StdoutRedirect}}};
  process::ExecutionTarget compileTestTarget = {
      .programPath = "/bin/env",
      .workingDirectory = workingDirectory,
      .argv = {std::string("mvn"), std::string("test-compile")},
      .env = {},
      .pipes = {{testCompilerPipe[0], testCompilerPipe[1],
                 process::redirect_target_t::StdoutRedirect}}};

  const pid_t srcCompilerPid = process::executeProcess(compileSrcTarget);
  const pid_t testCompilerPid = process::executeProcess(compileTestTarget);
  close(srcCompilerPipe[1]);
  close(testCompilerPipe[1]);
  pidList.push_front(srcCompilerPid);
  pidList.push_front(testCompilerPid);
  // we will be reading only from pipes
  evspec::Result result;
  process::waitPids(
      std::begin(pidList), std::end(pidList), true,
      [srcCompilerPid, testCompilerPid, srcCompilerPipe, testCompilerPipe,
       &result](pid_t pid) {
        namespace io = boost::iostreams;
        int fd = -1;
        if (pid == srcCompilerPid) {
          // source compilation failed, parse compilation error
          fd = srcCompilerPipe[0];
        } else if (pid == testCompilerPid) {
          // test compilation failed parse compilation error
          fd = testCompilerPipe[0];
        }
        if (fd == -1) {
          return;
        }
        io::stream_buffer<io::file_descriptor_source> streamBuffer(
            fd, io::never_close_handle);
        std::istream stream(&streamBuffer);
        std::vector<char> buffer(PIPE_BUF);
        std::string &target = fd == testCompilerPipe[0] ? result.testCompilerErr
                                                        : result.srcCompilerErr;
        while (stream) {
          std::size_t readCount = stream.readsome(buffer.data(), buffer.size());
          target.reserve(
              std::max(target.size() + readCount, target.capacity()));
          std::copy_n(std::begin(buffer), readCount,
                      std::back_inserter(target));
        }
      });
  // close pipes
  close(srcCompilerPipe[0]);
  close(testCompilerPipe[0]);

  return result;
}