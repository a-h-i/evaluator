#pragma once
#include "ev_spec_types.h"
#include <boost/filesystem/path.hpp>
#include <forward_list>
#include <string>

namespace evspec {

struct TestSuite {
  /*
   * must be absolute path
   */
  boost::filesystem::path const path;
};

struct TestCaseResult {
  std::string name, className, failureReason;
  double timeTaken;
  inline bool success() const { return failureReason.empty(); }
};

struct SuiteResult {
  std::string packageName;
  std::forward_list<TestCaseResult> testCases;
  std::size_t numCases = 0;
};

struct Result {
  std::string srcCompilerErr, testCompilerErr;
  std::forward_list<SuiteResult> results;
  inline bool compiled() const {
    return srcCompilerErr.empty() && testCompilerErr.empty();
  }
};

/**
 * @brief Java specs require a call to evspec::libxml::initialize before hand
 *
 */
class Spec {
public:
  /* path must be absolute */
  Spec(const boost::filesystem::path &srcPath,
       const std::forward_list<TestSuite> &suites, SpecType type,
       SpecSubtype subtype)
      : srcPath(srcPath), suites(suites), type(type), subtype(subtype){

                                                      };
  Spec(const Spec &);
  Spec(Spec &&) noexcept;
  Spec &operator=(Spec &&);
  Spec &operator=(const Spec &);
  Result const *run() noexcept(false);

  inline Result const *result() const { return &rslt; }

  ~Spec();

private:
  boost::filesystem::path srcPath;
  std::forward_list<TestSuite> suites;
  Result rslt;
  std::forward_list<boost::filesystem::path> createdDirectories;
  SpecType type;
  SpecSubtype subtype;
};

extern void (*const exitHandler)();
extern void (*const abortHandler)(int);
} // namespace evspec