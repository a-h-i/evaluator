#pragma once
#include "dll_imports.h"
#include "libssh/libssh.h"

namespace evspec {
namespace EVSPEC_LOCAL ssh {
class ssh_session_t {
  ssh_session session_ {nullptr};

 public:
  ~ssh_session_t();
  inline ssh_session operator->() { return session_; }
};
}  // namespace EVSPEC_LOCALssh
}  // namespace evspec