#include "java.h"
#include "process.h"

void evspec::java::createSuiteExtractionJobs(
    const fs::path &extractionDirectory,
    const std::forward_list<evspec::TestSuite> &suites,
    std::forward_list<pid_t> &pids, const fs::path &workingDirectory) {
  for (const evspec::TestSuite &suite : suites) {

    process::ExecutionTarget extractSuiteTarget = {
        .programPath = "/bin/env",
        .workingDirectory = workingDirectory,
        .argv = {std::string("atool"), std::string("-X"),
                 extractionDirectory.string(), suite.path.string()},
        .env = {}};
    pids.push_front(process::executeProcess(extractSuiteTarget));
  }
}

void evspec::java::createSrcExtractionJob(const fs::path &archiveExtractPath,
                                          const fs::path &srcPath,
                                          const fs::path &workingDirectory,
                                          std::forward_list<pid_t> &pidList) {
  process::ExecutionTarget archiveExtractTarget = {
      .programPath = "/bin/env",
      .workingDirectory = workingDirectory,
      .argv = {std::string("atool"), std::string("-X"),
               archiveExtractPath.string(), srcPath.string()},
      .env = {}};
  pidList.push_front(process::executeProcess(archiveExtractTarget));
}