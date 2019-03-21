#pragma once
#include <boost/program_options/variables_map.hpp>

namespace evworker::options {
  using ::boost::program_options::variables_map;
  variables_map parse_options(int argc, const char**argv);
  extern const char *NUM_WORKERS;
  extern const char *PID_DIRECTORY;
  extern const char *CONFIG_PATH;
  extern const char *CONFIG_PATH_SWITCH;
  extern const char *WORKER_EXE_PATH;
  typedef std::uint32_t num_workers_t;
  typedef std::string pid_file_t;
  typedef std::string worker_exe_path_t;
  
}