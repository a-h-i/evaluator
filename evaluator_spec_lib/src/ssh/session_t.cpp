#include "internal/ssh_session_t.h"
namespace evspec {
namespace ssh {
ssh_session_t::~ssh_session_t() {
  if (session_ != nullptr) {
    ssh_disconnect(session_);
    ssh_free(session_);
  }
}
}  // namespace ssh
}  // namespace evspec