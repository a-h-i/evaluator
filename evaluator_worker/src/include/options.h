#pragma once
#include <boost/program_options/variables_map.hpp>
#include <string>

namespace evworker::options {
using ::boost::program_options::variables_map;
variables_map parse_options(bool is_daemon, int argc, const char **argv);
extern const char *NUM_WORKERS;
extern const char *PID_DIRECTORY;
extern const char *CONFIG_PATH;
extern const char *CONFIG_PATH_SWITCH;
extern const char *WORKER_EXE_PATH;
extern const char *REDIS_CTRL_QUEUE;
extern const char *PARENT_UUID;
extern const char *REDIS_AUTH;
extern const char *REDIS_DB;
extern const char *REDIS_HOST;
extern const char *REDIS_PORT;
extern const char *BASE_PATH;
extern const char *DB_HOST;
extern const char *DB_PORT;
extern const char *DB_NAME;
extern const char *DB_USER;
extern const char *DB_PASS;
typedef std::uint32_t num_workers_t;
typedef std::string worker_exe_path_t;
typedef std::string redis_host_t;
typedef std::string redis_auth_t;
typedef std::string redis_ctrl_queue_t;
typedef std::string parent_uuid_t;
typedef int redis_port_t;
typedef int redis_db_t;
typedef int db_port_t;
}  // namespace evworker::options