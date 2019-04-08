#include "evspec.h"
#include "internal/virtual_base.h"

namespace evspec {
void delete_context(VirtualizationContext ctx) {
  delete reinterpret_cast<virtual_base_t *>(ctx);
}

virtual_base_t::~virtual_base_t() {}
}  // namespace evspec