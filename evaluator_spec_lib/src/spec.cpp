#include "evspec.h"
#include "java.h"
#include <boost/filesystem.hpp>
#include <exception>
#include <iostream>

namespace fs = boost::filesystem;

evspec::Result const *evspec::Spec::run() noexcept(false) {
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
    try {
      rslt = java::run(srcPath, homePath, tempPath, suites, type, subtype);
      return &rslt;
    } catch (...) {
      std::throw_with_nested(
          std::runtime_error("Spec::run unknown exception: "));
    }
  } else {
    std::throw_with_nested(std::runtime_error("Spec::run - Unknown spec type"));
  }
}

template <typename Cont>
void removeDirectories(const typename std::remove_reference<Cont>::type &list) {
  for (auto const &dir : list) {
    fs::remove_all(dir);
  }
}

evspec::Spec::~Spec() try {
  removeDirectories<decltype(createdDirectories)>(createdDirectories);
} catch (const std::exception &e) {
  // do nothing
  std::cerr << "evspec::Spec::~Spec: exception caught during destruction "
            << e.what() << '\n';
}

evspec::Spec::Spec(Spec &&other) noexcept { *this = other; }

evspec::Spec &evspec::Spec::operator=(Spec &&other) {
  removeDirectories<decltype(createdDirectories)>(createdDirectories);
  srcPath = std::move(other.srcPath);
  suites = std::move(other.suites);
  rslt = std::move(other.rslt);
  createdDirectories = std::move(other.createdDirectories);
  type = std::move(other.type);
  subtype = std::move(other.subtype);
  return *this;
}

evspec::Spec &evspec::Spec::operator=(const Spec &other) {
  removeDirectories<decltype(createdDirectories)>(createdDirectories);
  createdDirectories = other.createdDirectories;
  srcPath = other.srcPath;
  suites = other.suites;
  rslt = other.rslt;
  type = other.type;
  subtype = other.subtype;
  return *this;
}

evspec::Spec::Spec(const Spec &other) { *this = other; }
