#include <unistd.h>
#include <iostream>
#include <iterator>
#include <stdexcept>
#include <string>
#include "boost/filesystem.hpp"
#include "internal/ssh_command_t.h"
#include "internal/ssh_session_t.h"
#include "libssh/libssh.h"
#include "libssh/sftp.h"
#include "process.h"
#include "utils.h"

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
void ssh_session_t::mkdir_p(const boost::filesystem::path &dir) {
  std::string command = "mkdir -p ";
  command += dir.native().c_str();
  ssh_command_t(session_, command.c_str());
}
ssh_session_t::ssh_session_t(const std::string &host, const std::string &user,
                             const std::string &key_path)
    : session_(allocate_session()),
      key_path(boost::filesystem::canonical(key_path)),
      host(host),
      user(user) {
#ifdef DEBUG
  int verbosity = SSH_LOG_DEBUG;
#else
  int verbosity = SSH_LOG_WARN;
#endif
  ssh_options_set(session_, SSH_OPTIONS_HOST, host.c_str());
  ssh_options_set(session_, SSH_OPTIONS_USER, user.c_str());
  ssh_options_set(session_, SSH_OPTIONS_ADD_IDENTITY,
                  this->key_path.native().c_str());
  ssh_options_set(session_, SSH_OPTIONS_LOG_VERBOSITY, &verbosity);
}

ssh_session_t::ssh_session_t(const ssh_session_t &other) {
  ssh_options_copy(other, &session_);
}

bool ssh_session_t::connect(std::string *what) {
  int status = ssh_connect(session_);
  if (status == SSH_OK) {
    authenticate_host();
    if (ssh_userauth_autopubkey(session_, nullptr) != SSH_AUTH_SUCCESS) {
      if (what != nullptr) {
        *what = ssh_get_error(session_);
      }
      return false;
    }
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

void ssh_session_t::scp(boost::filesystem::path const &src,
                        boost::filesystem::path const &dest,
                        scp_direction_t::value_t direction) const {
  std::string src_scp, dest_scp;
  // we don't need to escape since process uses execve family not system
  if (direction == scp_direction_t::UPLOAD_DIRECTION) {
    src_scp = src.native().c_str();
    dest_scp = user + "@" + host + ":" + dest.native().c_str();
  } else {
    src_scp = user + "@" + host + ":" + src.native().c_str();
    dest_scp = dest.native().c_str();
  }
  int scp_stdout_pipe[2], scp_stderr_pipe[2];
  pipe(scp_stdout_pipe);
  pipe(scp_stderr_pipe);
  utility::wrapper_t([scp_stdout_pipe, scp_stderr_pipe]() {
    close(scp_stdout_pipe[0]);
    close(scp_stdout_pipe[1]);
    close(scp_stderr_pipe[0]);
    close(scp_stderr_pipe[1]);
  });

  std::string scp_flags("-rpB");
#ifdef DEBUG
  scp_flags += "v";
#endif
  process::ExecutionTarget scp_target = {
      .programPath = "/usr/bin/env",
      .workingDirectory = boost::filesystem::current_path(),
      .argv = {std::string("scp"), scp_flags, std::string("-i"),
               key_path.c_str(), src_scp, dest_scp},
      .env = {},
      .pipes = {{scp_stdout_pipe[0], scp_stdout_pipe[1],
                 process::redirect_target_t::StdoutRedirect},
                {scp_stderr_pipe[0], scp_stderr_pipe[1],
                 process::redirect_target_t::StderrRedirect}}};
  pid_t scp = process::executeProcess(scp_target);
  bool success = process::waitPid(scp, true, [](int) {});
  if (!success) {
    std::string err;
    utility::read_fd(std::back_inserter(err), scp_stdout_pipe[0]);
    utility::read_fd(std::back_inserter(err), scp_stderr_pipe[0]);
    std::cerr << err << std::endl;
    throw std::runtime_error("ssh_session_t::scp failed with error:\n" + err);
  }
}
void ssh_session_t::upload_directory(
    boost::filesystem::path const &local_path,
    boost::filesystem::path const &remote_path) {
  scp(local_path, remote_path, scp_direction_t::UPLOAD_DIRECTION);
}

void ssh_session_t::download_directory(
    boost::filesystem::path const &remote_path,
    boost::filesystem::path const &local_path) const {
  scp(remote_path, local_path, scp_direction_t::DOWNLOAD_DIRECTION);
}

void ssh_session_t::disconnect() { ssh_disconnect(session_); }

}  // namespace ssh
}  // namespace evspec