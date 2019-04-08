#include "internal/sftp_session_t.h"
#include <sys/stat.h>
#include <unistd.h>
#include <algorithm>
#include <fstream>
#include <stdexcept>
#include <string>
#include "boost/filesystem.hpp"
#include "internal/sftp_file.h"

namespace evspec {
namespace ssh {
sftp_session_t::sftp_session_t(ssh_session session_ssh) {
  session_ = sftp_new(session_ssh);
  if (session_ == nullptr) {
    throw std::runtime_error(
        "sftp_session_t::sftp_session_t: could not allocate sftp sesison");
  }
  if (sftp_init(session_) != SSH_OK) {
    sftp_free(session_);
    throw std::runtime_error(
        "sftp_sesion_t::sftp_session_t : could not initialize sftp session");
  }
}
sftp_session_t::~sftp_session_t() {
  if (session_ != nullptr) {
    sftp_free(session_);
  }
}

void sftp_session_t::mkdir(const boost::filesystem::path &dir_path) {
  sftp_mkdir(session_, dir_path.native().c_str(), S_IRWXU);
}
void sftp_session_t::mkdir_p(const boost::filesystem::path &dir_path) {
  for (auto &element : dir_path) {
    mkdir(element);
  }
}

void sftp_session_t::upload_directory(
    boost::filesystem::path const &local_path,
    boost::filesystem::path const &remote_path) {
  namespace fs = boost::filesystem;
  mkdir_p(remote_path);
  fs::path subpath;
  int level = 0;
  for (fs::recursive_directory_iterator itr(local_path);
       itr != fs::recursive_directory_iterator(); ++itr) {
    int itr_level = itr.level();
    if (itr_level < level) {
      do {
        --level;
        subpath.remove_filename();
      } while (itr_level != level);
    }
    if (fs::is_directory(itr->status())) {
      level++;
      subpath /= static_cast<fs::path>(*itr).filename();
      mkdir(remote_path / subpath);
    } else {
      upload_file(*itr, remote_path / subpath);
    }
  }
}

void sftp_session_t::upload_file(boost::filesystem::path const &local_path,
                                 boost::filesystem::path const &remote_path) {
  sftp_file_t file(session_, remote_path.native().c_str(),
                   SFTP_FILE_MODE::WRITE);
  std::ifstream in(local_path.native().c_str(),
                   std::ios::binary | std::ios::in | std::ios::ate);
  const std::size_t page_size = getpagesize();
  const std::size_t size = in.tellg();
  in.seekg(0);
  std::size_t read_bytes = 0;
  std::vector<char> buffer;
  buffer.resize(std::min(size, page_size));

  while (read_bytes != size) {
    const std::size_t to_read = std::min(buffer.size(), size - read_bytes);
    in.read(&buffer[0], to_read);
    auto written = file.write(&buffer[0], to_read);
    if (written < 0) {
      throw std::runtime_error(
          std::string("sftp_session_t::upload_file file write failed") +
          ssh_get_error(session_));
    }
    while (static_cast<std::size_t>(written) < to_read) {
      written += file.write(&buffer[written], to_read - written);
    }
    read_bytes += written;
  }
}

void sftp_session_t::download_file(boost::filesystem::path const &remote_path,
                   boost::filesystem::path const &local_path) {
  std::ofstream out(local_path.native().c_str(), std::ios::out | std::ios::binary | std::ios::trunc);
  sftp_file_t file(session_, remote_path.native().c_str(), SFTP_FILE_MODE::READ);
  const std::size_t page_size = getpagesize();
  const std::size_t file_size = file.attributes()->size;
  std::size_t written_bytes = 0;
  std::vector<char> buffer;
  buffer.resize(std::min(file_size, page_size));
  while(written_bytes != file_size) {
    const std::size_t buffer_size = std::min(buffer.size(), file_size - written_bytes);
    auto read = file.read(&buffer[0], buffer_size);
    if(read < 0) {
      throw std::runtime_error(
          std::string("sftp_session_t::upload_file file write failed") +
          ssh_get_error(session_));
    }
    auto start_pos = out.tellp();
    out.write(&buffer[0], read);
    auto end_pos = out.tellp();
    auto diff = end_pos - start_pos;
    while(diff < read) {
      out.write(&buffer[diff], read - diff);
      diff = out.tellp() - start_pos;
    }
    written_bytes += read;
  }
}

}  // namespace ssh
}  // namespace evspec