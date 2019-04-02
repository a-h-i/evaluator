#pragma once
#include <memory>
#include <string>
#include "boost/program_options/variables_map.hpp"
#include "options.h"

namespace evworker {

class Worker {
  std::unique_ptr<void, void (*)(void *)> ctx;

 public:
  Worker(const boost::program_options::variables_map *opts);
  /**
   * @brief processes queue
   *
   * @return std::size_t returns number of tasks processed
   */
  std::size_t process_queue();
  std::string worker_name();
};
}  // namespace evworker
