#pragma once
#include <boost/filesystem/path.hpp>
#include <forward_list>
#include <vector>
#include <string>
#include "dll_imports.h"

namespace EVSPEC_API evspec {

struct SpecType {
  enum spec_type_t : unsigned int { NULL_VALUE = 0, JAVA_1_8 = 0x01 };
  spec_type_t  value {NULL_VALUE};
  typedef spec_type_t value_t;
  inline bool isJavaType() const {
    switch (value) {
    case JAVA_1_8:
      return true;
    default:
      return false;
    }
  }
  inline bool isNullType() const {
    return value == NULL_VALUE;
  }
  SpecType() = default;
  inline SpecType(value_t value) : value(value) {}
  SpecType &operator=(const SpecType&) = default;
  SpecType(const SpecType &) = default;
};


enum class JUnitVersion : unsigned int { NULL_TYPE = 0, JUnit_3 = 0x01, JUnit_4 = 0x02, JUnit_5 = 0x03 };
union SpecSubtype {
  JUnitVersion junitVersion;
  SpecSubtype(const SpecSubtype &) = default;
  SpecSubtype &operator=(const SpecSubtype &) = default;
  SpecSubtype() : junitVersion(JUnitVersion::NULL_TYPE) {}
  SpecSubtype(const SpecType &type) {
    // default subtype
    switch (type.value) {
      case SpecType::JAVA_1_8:
        junitVersion = JUnitVersion::JUnit_3;
        break;
      default:
        junitVersion = JUnitVersion::NULL_TYPE;
    }
  }
  SpecSubtype(const SpecType &type, unsigned int subtype) {
    if(type.isJavaType()) {
      this->junitVersion = static_cast<JUnitVersion>(subtype);
    } else {
      this->junitVersion = JUnitVersion::NULL_TYPE;
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
typedef void * VirtualizationContext;

struct EvaluationContext {
  boost::filesystem::path srcPath;
  std::forward_list<TestSuite> suites;
  SpecType specType;
  SpecSubtype subtype;
};

} // namespace evspec