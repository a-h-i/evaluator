#pragma once
#include <memory>
#include "boost/filesystem/path.hpp"
#include "dll_imports.h"
#include "libssh/sftp.h"
namespace evspec {
namespace EVSPEC_LOCAL ssh {

class sftp_session_t {
  sftp_session session_{nullptr};

  void mkdir_p(const boost::filesystem::path &dir_path);
  void mkdir(const boost::filesystem::path &dir_path);
 public:
  explicit sftp_session_t(ssh_session session);
  inline sftp_session_t(sftp_session_t &&other) {
    std::swap(session_, other.session_);
  }
  inline sftp_session_t &operator=(sftp_session_t &&other) {
    std::swap(session_, other.session_);
    return *this;
  }
  sftp_session_t(const sftp_session_t &) = delete;
  sftp_session_t &operator=(sftp_session_t const &) = delete;
  inline explicit operator sftp_session() const { return session_; }
  /**
   * @brief uploads a directory
   *
   * @param local_path path to directory on local machine
   * @param remote_path path to directory on remote machine, created as if by
   * mkdir -p
   *
   */
  void upload_directory(boost::filesystem::path const &local_path,
                        boost::filesystem::path const &remote_path);
  void download_directory(boost::filesystem::path const &remote_path,
                          boost::filesystem::path const &local_path);
  void upload_file(boost::filesystem::path const &local_path,
                   boost::filesystem::path const &remote_path);
  void download_file(boost::filesystem::path const &remote_path,
                     boost::filesystem::path const &local_path);
  ~sftp_session_t();
};
}  // namespace EVSPEC_LOCALssh
}  // namespace evspec