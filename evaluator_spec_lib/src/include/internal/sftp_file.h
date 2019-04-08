#pragma once
#include <cstring>
#include <memory>
#include "dll_imports.h"
#include "libssh/sftp.h"
namespace evspec {
enum class SFTP_FILE_MODE : unsigned char { READ = 1, WRITE = 2 };
namespace EVSPEC_LOCAL ssh {
class sftp_attributes_t {
  sftp_attributes attr_{nullptr};
  bool new_allocated{false};

 public:
  inline sftp_attributes_t(sftp_attributes attr) : attr_(attr) {}
  inline sftp_attributes_t(const sftp_attributes_t &other) { *this = other; }
  inline sftp_attributes_t(sftp_attributes_t &&other)
      : new_allocated(other.new_allocated) {
    std::swap(attr_, other.attr_);
  }

  inline  sftp_attributes const &operator->() const { return attr_; }
  inline operator sftp_attributes() const { return attr_; }
  inline sftp_attributes_t &operator=(const sftp_attributes_t &other) {
    attr_ = new sftp_attributes_struct;
    new_allocated = true;
    std::memcpy(attr_, other.attr_, sizeof(sftp_attributes_struct));
    return *this;
  }

  inline sftp_attributes_t &operator=(sftp_attributes_t &&other) {
    new_allocated = other.new_allocated;
    std::swap(attr_, other.attr_);
    return *this;
  }

  inline ~sftp_attributes_t() {
    if (attr_ == nullptr) {
      return;
    }
    if (new_allocated) {
      delete attr_;
    } else {
      sftp_attributes_free(attr_);
    }
  }
};


class sftp_file_t {
  sftp_file file_{nullptr};

 public:
  sftp_file_t(sftp_session sftp, const char *path, SFTP_FILE_MODE mode);
  inline sftp_file_t(sftp_file_t &&other) noexcept {
    std::swap(file_, other.file_);
  }
  sftp_file_t(sftp_file_t const &other) = delete;
  sftp_file_t &operator=(const sftp_file_t &other) = delete;
  inline sftp_file_t &operator=(sftp_file_t &&other) {
    std::swap(file_, other.file_);
    return *this;
  }
  inline operator sftp_file() const { return file_; }
  inline sftp_attributes_t attributes() const { return sftp_fstat(file_); }
  
  inline long long int write(char const *cont, std::size_t num_bytes) {
    return sftp_write(file_, cont, num_bytes);
  }
  inline long long int read(char *cont, std::size_t num_bytes) {
    return sftp_read(file_, cont, num_bytes);
  }
  ~sftp_file_t();
};
}  // namespace EVSPEC_LOCALssh
}  // namespace evspec