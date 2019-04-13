#pragma once
#include <memory>
#include <string>
#include <vector>
#include "boost/filesystem/path.hpp"
#include "dll_imports.h"
#include "libssh/libssh.h"
namespace evspec {
namespace EVSPEC_LOCAL ssh {

class ssh_session_t {
  ssh_session session_{nullptr};
  const boost::filesystem::path key_path;
  const std::string host, user;
  void authenticate_host();
  struct scp_direction_t {
    typedef bool value_t;
    static constexpr value_t UPLOAD_DIRECTION = true;
    static constexpr value_t DOWNLOAD_DIRECTION = false;
  };

  void scp(boost::filesystem::path const &src,
           boost::filesystem::path const &dest, scp_direction_t::value_t) const;

 public:
  ssh_session_t(const std::string &host, const std::string &user,
                const std::string &key_path);
  inline ssh_session_t(ssh_session session) : session_(session) {}
  inline ssh_session_t(ssh_session_t &&other)
      : key_path(std::move(other.key_path)),
        host(std::move(other.host)),
        user(std::move(other.user)) {
    std::swap(session_, other.session_);
  }
  ssh_session_t(const ssh_session_t &);
  ssh_session_t operator=(const ssh_session_t &) = delete;
  ssh_session_t &operator=(ssh_session_t &&other) = delete;

  /**
   * @brief uploads a directory. Can also be a single file.
   *
   * @param local_path path to directory on local machine
   * @param remote_path path to directory on remote machine
   *
   */
  void upload_directory(boost::filesystem::path const &local_path,
                        boost::filesystem::path const &remote_path);
  void download_directory(boost::filesystem::path const &remote_path,
                          boost::filesystem::path const &local_path) const;
  std::vector<char> execute_command(const std::string &working_dir, const std::string &cmd,
                                                 const std::vector<std::string> &args);
  bool connect(std::string *what);
  bool is_connected() const;
  void mkdir_p(boost::filesystem::path const &dir);
  void rm(boost::filesystem::path const &p);
  void disconnect();
  ~ssh_session_t();
  inline ssh_session operator->() const { return session_; }
  inline explicit operator ssh_session() const { return session_; }
};
}  // namespace EVSPEC_LOCALssh
}  // namespace evspec