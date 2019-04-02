#pragma once
#include <exception>
#include <stdexcept>
#include <string>
#include "boost/filesystem/path.hpp"
#include "json.hpp"
#include "pg_ctx.h"
#include "pg_result.h"
#include "project.h"
#include "result.h"
#include "submission.h"
#include "test_suite.h"
namespace evworker::db {
namespace fs = boost::filesystem;
using nlohmann::json;
}  // namespace evworker::db