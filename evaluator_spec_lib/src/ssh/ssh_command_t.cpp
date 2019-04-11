#include "internal/ssh_command_t.h"
#include <stdexcept>
namespace evspec::ssh {

ssh_command_t::ssh_command_t(ssh_session session, const char* command) {
  channel_ = ssh_channel_new(session);
  if (channel_ == nullptr) {
    throw std::runtime_error(
        "ssh_command_t::ssh_command unable to allocate space for channel");
  }
  if(ssh_channel_open_session(channel_) != SSH_OK) {
    fprintf(stderr,"Error connecting to host %s\n",ssh_get_error(session));
    ssh_channel_free(channel_);
    throw std::runtime_error("ssh_command_t::ssh_command_t failed to open channel");
  }
  
  
  if (ssh_channel_request_exec(channel_, command) != SSH_OK) {
    close_channel();
    throw std::runtime_error(
        "ssh_command_t::ssh_command unable to execute command");
  }
}

ssh_command_t::~ssh_command_t() {
  if (channel_ != nullptr) {
    close_channel();
  }
}
void ssh_command_t::close_channel() {
  // ssh_channel_send_eof(channel_);
  ssh_channel_close(channel_);
  ssh_channel_free(channel_);
}
}  // namespace evspec::ssh