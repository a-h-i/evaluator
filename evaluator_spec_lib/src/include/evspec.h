#pragma once
#include "dll_imports.h"
#include "ev_spec_types.h"

namespace EVSPEC_API evspec {

/**
 * @brief Evaluates a submission using a virtualization context
 * You must ensure that libxml2 is initialized before calling this function
 * @return Result
 */
Result evaluateSubmission(const EvaluationContext *, VirtualizationContext *);

struct LibXmlRaii {
  LibXmlRaii();
  ~LibXmlRaii();
};

/**
 * @brief handlers for waiting on child processes.
 * No need to register if you already do that.
 * can call exitHandler() directly to just wait on children, it has no other
 * sideeffects. abortHandler does call std::_Exit though.
 *
 */
extern void (*const exitHandler)();
extern void (*const abortHandler)(int);
constexpr uint8_t version_major = VERSION_MAJOR;
constexpr uint8_t version_minor = VERSION_MINOR;
} // namespace EVSPEC_APIevspec