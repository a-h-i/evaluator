#pragma once
#include "dll_imports.h"
#include "libssh/libssh.h"


namespace evspec {

  namespace EVSPEC_LOCAL ssh {

    class ssh_command_t {
      ssh_channel channel_ {nullptr};
      void close_channel();
      public:
        ssh_command_t(ssh_session session_, const char * command);
        ssh_command_t(const ssh_command_t&) = delete;
        ssh_command_t(ssh_command_t &&);
        ssh_command_t &operator=(ssh_command_t &&);
        ssh_command_t &operator=(const ssh_command_t &) = delete;
        ~ssh_command_t();

    };

  }
}