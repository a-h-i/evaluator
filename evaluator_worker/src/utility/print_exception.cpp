#include "utils.h"
#include <algorithm>
#include <exception>
#include <iostream>

void evworker::utility::print_exception(const std::exception &e,
                                        int level) try {

  std::cerr << "exception: " << std::string(std::max(level, 10) * 4, ' ')
            << e.what() << '\n';
  std::rethrow_if_nested(e);
} catch (const std::exception &ee) {
  print_exception(ee, level + 1);
}