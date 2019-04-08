#pragma once
#include "dll_imports.h"
#include "libssh/libssh.h"
#include "boost/filesystem/path.hpp"
#include <string>
#include <memory>


namespace evspec {
namespace EVSPEC_LOCAL ssh {


class ssh_session_t {
  ssh_session session_ {nullptr};
  
  void authenticate_host();
 public:
  ssh_session_t(const std::string &host, const std::string &user, const std::string &key_path);
  inline ssh_session_t(ssh_session session) : session_(session) {}
  inline ssh_session_t(ssh_session_t &&other) {
    std::swap(session_, other.session_);
  }
  ssh_session_t(const ssh_session_t &);
  ssh_session_t operator=(const ssh_session_t &) = delete;
  inline ssh_session_t& operator=(ssh_session_t &&other) {
    std::swap(session_, other.session_);
    return *this;
  }

  /**
   * @brief uploads a directory
   * 
   * @param local_path path to directory on local machine
   * @param remote_path path to directory on remote machine
   * 
   */
  void upload_directory(boost::filesystem::path const &local_path, boost::filesystem::path const &remote_path);
  void download_directory(boost::filesystem::path const &remote_path, boost::filesystem::path const &local_path);
  bool connect(std::string *what);
  bool is_connected() const;
  void disconnect();
  ~ssh_session_t();
  inline ssh_session operator->() const { return session_; }
  inline operator ssh_session() const {return session_;}
};
}  // namespace EVSPEC_LOCALssh
}  // namespace evspec