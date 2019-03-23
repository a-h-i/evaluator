#pragma once
#include <memory>
#include "boost/program_options/variables_map.hpp"
#include "options.h"

namespace evworker {

class Worker {
  std::unique_ptr<void, void (*)(void *)> ctx;

 public:
  Worker(const boost::program_options::variables_map &opts);
  /**
   * @brief processes queue
   *
   * @return std::size_t returns number of tasks processed
   */
  std::size_t process_queue();
};
}  // namespace evworker
