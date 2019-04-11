#define BOOST_TEST_MODULE evspec - ssh
#include <boost/test/unit_test.hpp>
#include "internal/ssh_session_t.h"
#include "boost/filesystem.hpp"

using namespace evspec::ssh;
using namespace boost::filesystem;
struct AuthInfo {
  static const std::string host;
  static const std::string user;
  static const std::string key_path;
};
const std::string AuthInfo::host = "10.0.3.226";
const std::string AuthInfo::user = "root";
const std::string AuthInfo::key_path = "/home/ahi/.ssh/id_rsa";

struct SSHContext {
  static ssh_session_t create_session() {
    return ssh_session_t(AuthInfo::host, AuthInfo::user, AuthInfo::key_path);
  }
};

BOOST_AUTO_TEST_SUITE(ssh_specs)

BOOST_AUTO_TEST_CASE(connects) {
  ssh_session_t session = SSHContext::create_session();
  BOOST_ASSERT(session.connect(nullptr));
  BOOST_ASSERT(session.is_connected());
}

BOOST_AUTO_TEST_CASE(test_file_upload) {
  ssh_session_t session = SSHContext::create_session();
  session.connect(nullptr);
  path src("fixtures/test_file");
  BOOST_ASSERT(session.is_connected());
  session.mkdir_p("test/upload");
  session.upload_directory(absolute(src), "test/upload/test_file");
}


BOOST_AUTO_TEST_SUITE_END()

