
# One per core at least
worker_processes 2

working_directory "/root/evaluator/evaluator_api"

listen '127.0.0.1:3000'

# Kill workers ater 50 seconds
timeout 50

pid "/var/run/evaluator/unicorn.pid"

preload_app true

stderr_path "/var/log/evaluator/unicorn.err.log"
stdout_path "/var/log/evaluator/unicorn.out.log"
check_client_connections false
run_once = true

before_fork do |server, worker|
  ActiveRecord::Base.connection.disconnect!
  old_pid = "#{server.config[:pid]}.oldbin"
  if old_pid != server.pid
    begin
      sig = (worker.nr + 1) >= server.worker_processes ? :QUIT : :TTOU
      Process.kill(sig, File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
    end
  end
  sleep 1
  after_fork do |server, worker|
  
    ActiveRecord::Base.establish_connection
  
    # if preload_app is true, then you may also want to check and
    # restart any other shared sockets/descriptors such as Memcached,
    # and Redis.  TokyoCabinet file handles are safe to reuse
    # between any number of forked children (assuming your kernel
    # correctly implements pread()/pwrite() system calls)
    Rails.application.config.create_redis_connections(Rails.application.config)
  end
end
