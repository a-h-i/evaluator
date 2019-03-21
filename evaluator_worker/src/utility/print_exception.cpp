#include "utils.h"
#include <exception>
#include <iostream>

void evworker::utility::print_exception(const std::exception &e) try {
  std::cerr << "exception: " << e.what() << '\n';
  std::rethrow_if_nested(e);
} catch (const std::exception &ee) {
  print_exception(ee);
}