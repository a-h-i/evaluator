#include "evspec.h"
#include "java.h"
#include "process.h"

#include <exception>
#include <forward_list>
#include <iterator>
#include <limits.h>
#include <string>
#include <sys/wait.h>
#include <unistd.h>
#include <vector>

static void runTests(evspec::Result &, const fs::path &workingDirectory);

evspec::Result evspec::java::run(const fs::path &srcPath,
                                 const fs::path &homePath,
                                 const fs::path &tempPath,
                                 const std::forward_list<TestSuite> &suites,
                                 SpecType specType,
                                 SpecSubtype subType) noexcept(false) {
  try {
    std::forward_list<pid_t> pidList;
    // Write pom.xml
    writePom(homePath, specType, subType.junitVersion);
    // create directory structure for maven (src directory, test directory)
    std::pair<fs::path, fs::path> mvnDirectories =
        createMavenDirectoryStructore(homePath);
    const fs::path archiveExtractPath(fs::path(tempPath) /= srcPath.stem());
    // create a directory to inflate to
    fs::create_directories(archiveExtractPath);
    // extract src archive to archiveExtractPath
    createSrcExtractionJob(archiveExtractPath, srcPath, tempPath, pidList);
    // extract test suites directly to the tests maven directory
    createSuiteExtractionJobs(mvnDirectories.second, suites, pidList, tempPath);
    process::waitPids(
        std::begin(pidList), std::end(pidList), true, [](pid_t pid) {
          throw std::runtime_error("java::run::failLambda : extraction process "
                                   "exited abnormally. pid: " +
                                   std::to_string(pid));
        });

    pidList.clear();
    // src is an eclipse export
    mvEclipseSrcDirectory(tempPath, archiveExtractPath,
                          mvnDirectories.first.string());

    // Compile src and test source
    Result result = compile(homePath);

    // Run tests
    runTests(result, homePath);

    // Parse results
    return result;
  } catch (const std::exception &e) {
    std::throw_with_nested(std::runtime_error("java::run : Caught exception"));
  }
}

static void runTests(evspec::Result &result, const fs::path &workingDirectory) {
  process::ExecutionTarget target = {
      .programPath = "/bin/env",
      .workingDirectory = workingDirectory,
      .argv = {std::string("mvn"), std::string("test")},
      .env = {}};
  // TODO: Use virtualization library
  pid_t pid = process::executeProcess(target);
  process::waitPid(pid, true, []([[maybe_unused]] pid_t pid) {

  });
  if (result.compiled()) {
    evspec::java::parseTestResults(result, workingDirectory);
  }
}
