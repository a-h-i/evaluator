#include "evspec.h"
#include "java.h"
#include <boost/filesystem.hpp>
#include <exception>
#include <iostream>

namespace fs = boost::filesystem;

evspec::Result const * evspec::Spec::run() noexcept(false) {
  // Create temporary directory to use as home for sandboxed application
  fs::path homePath, tempPath;
  try {
    const fs::path tempDirPath = fs::temp_directory_path();
    homePath = fs::path(tempDirPath) /= fs::unique_path();
    fs::create_directories(homePath);
    createdDirectories.push_front(homePath);
    tempPath = fs::path(tempDirPath) /= fs::unique_path();
    fs::create_directories(tempPath);
    createdDirectories.push_front(tempPath);
  } catch (...) {
    std::throw_with_nested(std::runtime_error(
        "Spec::run Could not create temp directorsies for sandbox"));
  }

  if (type == SpecType::JAVA_1_8) {
    rslt = java::run(srcPath, homePath, tempPath, suites, type, subtype);
    return &rslt;
  } else {
    std::throw_with_nested(std::runtime_error("Spec::run - Unknown spec type"));
  }
}

evspec::Spec::~Spec() try {
  for(auto const &dir: createdDirectories) {
    fs::remove_all(dir);
  }
} catch(const std::exception &e) {
  // do nothing
  std::cerr << "evspec::Spec::~Spec: exception caught during destruction " << e.what() << '\n';
}


