#include <boost/filesystem.hpp>
#include <exception>
#include <forward_list>
#include "evspec.h"
#include "internal/java.h"
#include "internal/utils.h"
#include "raii/scope_rai.h"

namespace fs = boost::filesystem;

evspec::Result evspec::evaluateSubmission(
    const EvaluationContext *evaluationCtxPtr,
    VirtualizationContext *virtualizationCtxPtr) {
  std::forward_list<fs::path> createdDirectories;
  auto dirDeleter = [&createdDirectories] {
    utility::removeDirectories<decltype(createdDirectories)>(createdDirectories,
                                                             false);
  };
  raii::ScopeRaii createdDirectoriesScopeRai(dirDeleter);
  try {
    createdDirectories.push_front(utility::createTempDirectory());
    createdDirectories.push_front(utility::createTempDirectory());
  } catch (...) {
    std::throw_with_nested(std::runtime_error(
        "evspec::evaluateSubmission : Could not create temp directories"));
  }
  auto homePathItr = createdDirectories.cbegin();
  auto tempPathItr = ++createdDirectories.cbegin();
  if (evaluationCtxPtr->specType.isJavaType()) {
    return java::run(evaluationCtxPtr->srcPath, *homePathItr, *tempPathItr,
                     evaluationCtxPtr->suites, evaluationCtxPtr->specType,
                     evaluationCtxPtr->subtype, virtualizationCtxPtr);
  } else if (evaluationCtxPtr->specType.isNullType()) {
    return Result();
  } else {
    throw std::runtime_error("evspec::evaluateSubmission : Unknown spec type");
  }
}