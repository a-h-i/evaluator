#pragma once
#include <boost/filesystem.hpp>
#include <iostream>

namespace utility {
template <typename Cont>
void removeDirectories(const typename std::remove_reference<Cont>::type &list, bool rethrow = false) try {
  for (auto const &dir : list) {
    boost::filesystem::remove_all(dir);
  }
} catch(const std::exception &e) {
  if(rethrow) {
    throw e;
  } else {
std::cerr << "evspec::Spec::~Spec: exception caught during destruction "
                << e.what() << std::endl;
  }
}

inline boost::filesystem::path createTempDirectory() {
  boost::filesystem::path tempDirPath = boost::filesystem::temp_directory_path();
  boost::filesystem::path path = tempDirPath / boost::filesystem::unique_path();
  boost::filesystem::create_directories(path);
  return path;
}

template<class Obj, class Func , Func f>
struct apply_wrapper_t {
  Obj obj_;
  apply_wrapper_t(Obj obj) : obj_(obj) {};
  ~apply_wrapper_t() {
    f(obj_);
  }
};

} // namespace utility