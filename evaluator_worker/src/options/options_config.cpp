#include "options.h"

namespace evworker::options {
const char *NUM_WORKERS{"worker.num_workers"};
const char *PID_DIRECTORY{"worker.pid_dir"};
const char *CONFIG_PATH_SWITCH = "-C";
const char *CONFIG_PATH = "config";
const char *WORKER_EXE_PATH = "worker.exe_path";
const char *REDIS_CTRL_QUEUE = "redis.control_queue";
const char *PARENT_UUID = "uuid";
const char *REDIS_AUTH = "redis.auth";
const char *REDIS_DB = "redis.db";
const char *REDIS_HOST = "redis.host";
const char *REDIS_PORT = "redis.port";
const char *BASE_PATH = "data.dir";
const char *DB_HOST = "db.host";
const char *DB_PORT = "db.port";
const char *DB_NAME = "db.name";
const char *DB_USER = "db.user";
const char *DB_PASS = "db.password";
}  // namespace evworker::options