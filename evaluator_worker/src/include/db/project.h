#pragma once
#include <cstdint>
#include "evspec/evspec.h"
#include "json.hpp"

namespace evworker::db {
    struct project_t {
    
    std::uint64_t id;
    nlohmann::json detail;
    static const char *spec_type_attr;
    static const char *spec_subtype_attr;
    inline evspec::SpecType spec_type() {
      if(detail.count(spec_type_attr)) {
        evspec::SpecType::value_t value = static_cast<evspec::SpecType::value_t>(detail[spec_type_attr].get<unsigned int>());
        return evspec::SpecType(value);
      } else  {
        return evspec::SpecType();
      }
    }
    inline evspec::SpecSubtype subtype() {
      if(detail.count(spec_subtype_attr)) {
        return evspec::SpecSubtype(spec_type(), detail[spec_subtype_attr].get<unsigned int>());
      } else {
        return evspec::SpecSubtype(spec_type());
      }
    }
  };
}