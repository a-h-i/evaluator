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
    if (is_connected()) {
      disconnect();
    }
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
  if (status == SSH_OK) {
    authenticate_host();
    return true;
  } else {
    if (what != nullptr) {
      *what = ssh_get_error(session_);
    }
    return false;
  }
}
bool ssh_session_t::is_connected() const { return ssh_is_connected(session_); }
void ssh_session_t::authenticate_host() {
  enum ssh_known_hosts_e state = ssh_session_is_known_server(session_);
  switch (state) {
    case SSH_KNOWN_HOSTS_OK:
      break;
    default:
      ssh_session_update_known_hosts(session_);
  }
}

void ssh_session_t::disconnect() { ssh_disconnect(session_); }


}  // namespace ssh
}  // namespace evspec