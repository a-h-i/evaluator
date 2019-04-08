#include "evspec.h"
#include "internal/lxc.h"


namespace evspec {
  VirtualizationContext make_lxc_context(const std::string &container_name, const std::string &ssh_key_path) {
    return dynamic_cast<virtual_base_t *>(new lxc::lxc_ctx_t(container_name, ssh_key_path));
  }

}