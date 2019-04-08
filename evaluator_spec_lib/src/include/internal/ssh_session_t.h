#pragma once
#include "dll_imports.h"
#include "libssh/libssh.h"
#include <string>
#include <memory>

namespace evspec {
namespace EVSPEC_LOCAL ssh {
class ssh_session_t {
  ssh_session session_ {nullptr};

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
  bool connect(std::string *what);
  ~ssh_session_t();
  inline ssh_session operator->() const { return session_; }
  inline operator ssh_session() const {return session_;}
};
}  // namespace EVSPEC_LOCALssh
}  // namespace evspec