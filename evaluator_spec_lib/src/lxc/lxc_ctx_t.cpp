#include <unistd.h>
#include <istream>
#include <stdexcept>
#include "boost/filesystem.hpp"
#include "boost/regex.hpp"
#include "internal/lxc.h"
#include "utils.h"
#include "process.h"
namespace evspec::lxc {
// Sample lxc-ls output
// NAME                STATE   AUTOSTART GROUPS IPV4       IPV6 UNPRIVILEGED
// evaluator_container RUNNING 1         -      10.0.3.226 -    false

static std::string get_container_ip(const std::string &container_name) {
  const boost::regex ipv4_regex(
      "^" + container_name +
      R"([[:blank:]]+RUNNING[[:blank:]]+[0-1][[:blank:]]+.[[:blank:]]+([^[:blank:]]+)[[:blank:]]+.+$)");
  int lxc_ls_pipe[2];
  pipe(lxc_ls_pipe);
  utility::apply_wrapper_t<int, decltype(&close), close> pipe_wrap(
      lxc_ls_pipe[0]);
  process::ExecutionTarget target{
      .programPath = "/usr/bin/env",
      .workingDirectory = fs::current_path(),
      .argv = {std::string("lxc-ls"), std::string("-f")},
      .env = {},
      .pipes = {{lxc_ls_pipe[0], lxc_ls_pipe[1],
                 process::redirect_target_t::StdinRedirect}}};
  const pid_t child = process::executeProcess(target);
  close(lxc_ls_pipe[1]);  // close write end
  bool failed = false;
  process::waitPid(child, true, [&failed](int) { failed = true; });
  if (failed) {
    throw std::runtime_error(
        "evspec::lxc::get_container_ip failed to get ip for : " +
        container_name);
  }
  std::istream stream = utility::transform_fd_read(lxc_ls_pipe[0]);
  boost::smatch match;
  for (std::string line; std::getline(stream, line);) {
    if (boost::regex_match(line, match, ipv4_regex)) {
      return match[1];
    }
  }
  throw std::runtime_error(
      "evspec::lxc::get_container_ip failed to parse ip from lxc-ls -f "
      "output ");
}

lxc_ctx_t::lxc_ctx_t(const std::string &name,
                     const std::string &lxc_key_path_str)
    : container_name(name),
      ssh_key_path(lxc_key_path_str),
      ip(get_container_ip(name)) {}

lxc_ctx_t::~lxc_ctx_t() {}
}  // namespace evspec::lxc