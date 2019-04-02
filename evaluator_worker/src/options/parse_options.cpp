#include <iostream>
#include "boost/program_options.hpp"
#include "options.h"
//
// ─── WE PARSE OPTIONS FROM THE COMMAND LINE AS WELL AS A CONFIGURATION FILE
// ─────
//
using namespace boost::program_options;
static const char* LICENSE = R"LIC(
MIT License

Copyright (c) 2017 Ahmed H. Ismail <ahm3d.hisham@gmail.com>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
)LIC";

namespace evworker::options {
static void print_version() {
  std::cout << "Evaluator background worker version : " << VERSION_MAJOR << '.'
            << VERSION_MINOR << '\n'
            << LICENSE << std::endl;
  std::exit(0);
}
variables_map parse_options(bool is_daemon, int argc, const char** argv) {
  variables_map cli_vm, config_vm;
  options_description command_line_opts("Command Line Options"),
      config_file_opts("Configuration file options");
  bool help(false), version(false);
  command_line_opts.add_options()("version,v", bool_switch(&version),
                                  "prints version and exits")(
      "help,h", bool_switch(&help), "produces this help message and exits")(
      "config,C", value<std::string>(), "configuration file path")(
      PARENT_UUID, value<std::string>(), "parent uuid");

  config_file_opts.add_options()(
      NUM_WORKERS, value<num_workers_t>()->required(), "number of workers")(
      PID_DIRECTORY, value<std::string>()->required(), "pid directory")(
      WORKER_EXE_PATH, value<worker_exe_path_t>()->required(),
      "path to worker executable")(REDIS_CTRL_QUEUE,
                                   value<redis_ctrl_queue_t>()->required(),
                                   "redis control queue")(
      REDIS_AUTH, value<redis_auth_t>(), "redis authentication")(
      REDIS_DB, value<redis_db_t>()->required(), "redis database")(
      REDIS_HOST, value<redis_host_t>()->required(), "redis host address")(
      REDIS_PORT, value<redis_port_t>()->required(), "redis port number")(
      SUBMISSION_BASE_PATH, value<std::string>()->required(), "evaluator submissions data directory")(
      SUITES_BASE_PATH, value<std::string>()->required(), "evaluator test suite data directory")(
      DB_HOST, value<std::string>()->required(), "database host")(
      DB_PORT, value<db_port_t>()->required(), "database port")(
      DB_NAME, value<std::string>()->required(), "database name")(
      DB_USER, value<std::string>()->required(), "database username")(
      DB_PASS, value<std::string>()->required(), "database user password");

  auto parser = command_line_parser(argc, argv).options(command_line_opts);
  store(parser.run(), cli_vm);

  notify(cli_vm);
  if (help) {
    std::cout << command_line_opts << config_file_opts << std::endl;
    std::exit(0);
  } else if (version) {
    print_version();
  }

  if (!is_daemon && cli_vm.count(options::PARENT_UUID) != 1) {
    throw std::runtime_error("Could not parse parent uuid for worker");
  }
  if (cli_vm.count("config") != 1) {
    throw std::runtime_error("config file is required.");
  }
  store(parse_config_file<char>(cli_vm[CONFIG_PATH].as<std::string>().c_str(),
                                config_file_opts, false),
        config_vm);
  notify(config_vm);
  config_vm.insert(std::begin(cli_vm), std::end(cli_vm));
  return config_vm;
}
}  // namespace evworker::options