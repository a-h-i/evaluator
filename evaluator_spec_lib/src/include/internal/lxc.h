#pragma once
#include <string>
#include "virtual_base.h"
#include "dll_imports.h"
#include "boost/filesystem/path.hpp"

namespace evspec {
namespace EVSPEC_LOCAL lxc {
  namespace fs = boost::filesystem;
class lxc_ctx_t : public virtual_base_t {
  const std::string container_name;
  const fs::path ssh_key_path;
  const std::string ip;
  
 public:
  lxc_ctx_t(const std::string &container_name, const std::string &ssh_key_path);
  virtual ~lxc_ctx_t();
};
}  // namespace EVSPEC_LOCALlxc
}  // namespace evspec