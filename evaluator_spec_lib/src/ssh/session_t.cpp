#include <stdexcept>
#include "internal/ssh_session_t.h"

namespace evspec {
namespace ssh {

static ssh_session allocate_session() {
  ssh_session session = ssh_new();
  if (session == nullptr) {
    throw std::runtime_error(
        "ssh::ssh_session_t could not allocate session object");
  }
  return session;
}
ssh_session_t::~ssh_session_t() {
  if (session_ != nullptr) {
    ssh_disconnect(session_);
    ssh_free(session_);
  }
}

ssh_session_t::ssh_session_t(const std::string &host, const std::string &user,
                             const std::string &key_path)
    : session_(allocate_session()) {
  ssh_options_set(session_, SSH_OPTIONS_HOST, host.c_str());
  ssh_options_set(session_, SSH_OPTIONS_USER, user.c_str());
  ssh_options_set(session_, SSH_OPTIONS_ADD_IDENTITY, key_path.c_str());
}

ssh_session_t::ssh_session_t(const ssh_session_t &other) {
  ssh_options_copy(other, &session_);
}

bool ssh_session_t::connect(std::string *what) {
  int status = ssh_connect(session_);
  if(status == SSH_OK) {
    return true;
  } else {
    if(what != nullptr) {
      *what = ssh_get_error(session_);
    }
    return false;
  }
}
}  // namespace ssh
}  // namespace evspec