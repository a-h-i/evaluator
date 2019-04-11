#include "utils.h"

namespace evspec::utility {

boost::filesystem::path createTempDirectory() {
  boost::filesystem::path tempDirPath =
      boost::filesystem::temp_directory_path();
  boost::filesystem::path path = tempDirPath / boost::filesystem::unique_path();
  boost::filesystem::create_directories(path);
  return path;
}


}  // namespace evspec::utility