#pragma once
#include "evspec.h"
#include <boost/filesystem.hpp>
#include <forward_list>
#include <string>
#include <utility>
#include <vector>

namespace fs = boost::filesystem;
namespace evspec::java {
void createSrcExtractionJob(const fs::path &archiveExtractPath,
                            const fs::path &srcPath,
                            const fs::path &workingDirectory,
                            std::forward_list<pid_t> &pidList);
void writePom(const fs::path &homePath, const SpecType &specType,
              const JUnitVersion &junitVersion);
void parseTestResults(Result &result, const fs::path &workingDirectory);
void mvEclipseSrcDirectory(const fs::path &workingDirectory,
                           const fs::path &archiveExtractPath,
                           const fs::path &mvnSrcDirectory);
evspec::Result compile(const fs::path &workingDirectory);
Result run(const fs::path &srcPath, const fs::path &homePath,
           const fs::path &tempPath, const std::forward_list<TestSuite> &suites,
           SpecType specType, SpecSubtype subType) noexcept(false);
void createSuiteExtractionJobs(const fs::path &extractionTarget,
                               const std::forward_list<evspec::TestSuite> &,
                               std::forward_list<pid_t> &,
                               const fs::path &workingDirectory);
/**
 * @returns pair (main, test)
 *
 */
inline std::pair<fs::path, fs::path>
createMavenDirectoryStructore(const fs::path &homePath) {
  fs::path mainJavaDirectory(homePath), testJavaDirectory(homePath);
  mainJavaDirectory /= fs::path("src/main/java");
  testJavaDirectory /= fs::path("src/test/java");
  fs::create_directories(mainJavaDirectory);
  fs::create_directories(testJavaDirectory);
  return std::pair<fs::path, fs::path>(mainJavaDirectory, testJavaDirectory);
}

std::vector<fs::path> extractArchives(const fs::path &tempPath);

} // namespace evspec::java