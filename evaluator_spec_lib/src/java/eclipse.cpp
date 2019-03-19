#include "internal/java.h"
#include "process.h"

void evspec::java::mvEclipseSrcDirectory(const fs::path &workingDirectory,
                                  const fs::path &archiveExtractPath,
                                  const fs::path &mvnSrcDirectory) {
  // NOTE: Archive is an eclipse project export
  // copy extracted src to main maven directory
  // we recursively search for a src directory
  fs::recursive_directory_iterator search_itr(archiveExtractPath);
  bool found = false;
  pid_t pid;
  while (search_itr != fs::recursive_directory_iterator()) {
    found = fs::is_directory(search_itr->path()) &&
            search_itr->path().filename() == "src";
    if (found) {
      process::ExecutionTarget srcMvTarget = {
          .programPath = "/bin/env",
          .workingDirectory = workingDirectory,
          .argv = {std::string("mv"), search_itr->path().string(),
                   mvnSrcDirectory.string()},
          .env = {}};
      pid = process::executeProcess(srcMvTarget);
      break;
    }
    ++search_itr;
  }
  if (!found) {
    // was unable to find src directory
    throw std::runtime_error(
        "java::run : Unable to find src directory for extracted archive");
  }
  process::waitPid(pid, true, [](pid_t pid) {
    throw std::runtime_error("java::run::failLambda : src mv process "
                             "exited abnormally. pid: " +
                             std::to_string(pid));
  });
}