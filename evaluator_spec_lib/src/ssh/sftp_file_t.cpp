#include <fcntl.h>
#include <sys/stat.h>
#include "internal/sftp_file.h"
#include <string>

namespace evspec {
namespace ssh {

sftp_file_t::~sftp_file_t() {
  if (file_ != nullptr) {
    sftp_close(file_);
  }
}

sftp_file_t::sftp_file_t(sftp_session sftp, const char *path,
                         SFTP_FILE_MODE mode) {
  int accesstype;
  auto open_mode = S_IRWXU;
  switch (mode) {
    case SFTP_FILE_MODE::READ:
      accesstype = O_RDONLY;
      break;
    case SFTP_FILE_MODE::WRITE:
    default:
      accesstype = O_RDWR | O_CREAT | O_TRUNC;
  }
  file_ = sftp_open(sftp, path, accesstype, open_mode);
  if(file_ == nullptr) {
    throw std::runtime_error(std::string("sftp_file_t::sftp_file_t failed to open : ")  + path);
  }
}
}  // namespace ssh
}  // namespace evspec