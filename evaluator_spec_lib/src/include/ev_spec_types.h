#pragma once
#include <boost/filesystem/path.hpp>
#include <forward_list>
#include <vector>
#include <string>
#include "dll_imports.h"

namespace EVSPEC_API evspec {

struct SpecType {
  enum spec_type_t : unsigned int { NULL_VALUE = 0, JAVA_1_8 = 0x01 } value;
  bool isJavaType() const {
    switch (value) {
    case JAVA_1_8:
      return true;
    default:
      return false;
    }
  }
  bool isNullType() const {
    return value == NULL_VALUE;
  }
  SpecType() = default;
  SpecType(decltype(value) value) : value(value) {}
  explicit SpecType(unsigned int value) : value(static_cast<spec_type_t>(value)) {
  }
  SpecType &operator=(decltype(value) value) {
    this->value = value;
    return *this;
  }
  operator decltype(value)() const { return value; };
};

enum class JUnitVersion : unsigned int { NULL_TYPE = 0, JUnit_3 = 0x01, JUnit_4, JUnit_5 };
union SpecSubtype {
  JUnitVersion junitVersion;
  SpecSubtype() : junitVersion(JUnitVersion::NULL_TYPE) {}
  SpecSubtype(const SpecType &type) {
    // default subtype
    switch (type) {
      case SpecType::JAVA_1_8:
        junitVersion = JUnitVersion::JUnit_3;
        break;
      default:
        junitVersion = JUnitVersion::NULL_TYPE;
    }
  }
  SpecSubtype(const SpecType &type, unsigned int subtype) {
    switch(type) {
      case SpecType::JAVA_1_8:
        junitVersion = static_cast<JUnitVersion>(subtype);
        break;
      default:
        junitVersion = JUnitVersion::NULL_TYPE;
    }
  }
  SpecSubtype(JUnitVersion vers) : junitVersion(vers) {}
  SpecSubtype &operator=(JUnitVersion junitVersion) {
    this->junitVersion = junitVersion;
    return *this;
  }
};

struct TestSuite {
  /*
   * must be absolute path
   */
  boost::filesystem::path const path;
  TestSuite(const boost::filesystem::path &path) : path(path) {}
};

/**
 * @brief Result of a single test case, usually contained inside a SuiteResult.
 *
 */
struct TestCaseResult {
  std::string name, className, failureReason;
  double timeTaken;
  inline bool success() const { return failureReason.empty(); }
};

/**
 * @brief Result of a testsuite
 *
 */
struct SuiteResult {
  std::string packageName;
  std::vector<TestCaseResult> testCases;
  std::size_t numCases = 0;
};

/**
 * @brief Result of compiling and testing a src package against n test suite(s)
 *
 */
struct Result {
  std::string srcCompilerErr, testCompilerErr;
  std::forward_list<SuiteResult> results;
  inline bool compiled() const {
    return srcCompilerErr.empty() && testCompilerErr.empty();
  }
};
/**
 * @brief Virtualization backend
 *
 */
struct VirtualizationContext;

struct EvaluationContext {
  boost::filesystem::path srcPath;
  std::forward_list<TestSuite> suites;
  SpecType specType;
  SpecSubtype subtype;
};

} // namespace evspec