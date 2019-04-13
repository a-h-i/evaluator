#include "internal/ssh_command_t.h"
#include <linux/limits.h>
#include <algorithm>
#include <cstring>
#include <memory>
#include <stdexcept>
#include <string>
namespace evspec {
namespace ssh {

ssh_command_t::ssh_command_t(ssh_session session, const char *command)
    : command_(command) {
  channel_ = ssh_channel_new(session);
  if (channel_ == nullptr) {
    throw std::runtime_error(
        "ssh_command_t::ssh_command unable to allocate space for channel");
  }
  if (ssh_channel_open_session(channel_) != SSH_OK) {
    fprintf(stderr, "Error connecting to host %s\n", ssh_get_error(session));
    ssh_channel_free(channel_);
    throw std::runtime_error(
        "ssh_command_t::ssh_command_t failed to open channel");
  }
}

ssh_command_t::ssh_command_t(ssh_command_t &&other)
    : command_(std::move(other.command_)) {
  std::swap(channel_, other.channel_);
}

ssh_command_t &ssh_command_t::operator=(ssh_command_t &&other) {
  std::swap(channel_, other.channel_);
  command_ = std::move(other.command_);
  return *this;
}

void ssh_command_t::execute() {
  if (ssh_channel_request_exec(channel_, command_.c_str()) != SSH_OK) {
    close_channel();
    throw std::runtime_error(
        "ssh_command_t::ssh_command unable to execute command");
  }
}

std::vector<char> ssh_command_t::read(bool std_error) const {
  std::vector<char> data;
  if(ssh_channel_poll_timeout(channel_, 500, std_error) <= 0) {
    return data;
  }
  std::unique_ptr<char[]> buffer(new char[PIPE_BUF]);
  int i = 0;
  do {
    i = ssh_channel_read(channel_, buffer.get(), PIPE_BUF, std_error);
    if (i > 0) {
      std::size_t offset = data.size();
      data.resize(offset + i);
      std::memcpy(&data[offset], buffer.get(), i);
    }
  } while (i > 0);
  return data;
}
void ssh_command_t::write(const char *src, std::size_t size) {
  int written = 0;
  do {
    written = ssh_channel_write(channel_, src + written, size - written);

  } while ((written != SSH_ERROR) &
           (static_cast<std::size_t>(written) != size));
  if (written == SSH_ERROR) {
  }
}
ssh_command_t::~ssh_command_t() {
  if (channel_ != nullptr) {
    close_channel();
  }
}
void ssh_command_t::close_channel() {
  ssh_channel_send_eof(channel_);
  ssh_channel_close(channel_);
  ssh_channel_free(channel_);
}
}  // namespace ssh
}  // namespace evspec