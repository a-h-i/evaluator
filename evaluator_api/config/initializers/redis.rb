

Rails.application.configure do
  config.action_controller.perform_caching = false
  config.create_redis_connections = Proc.new do |config|
    config.redis = Redis.new(driver: :hiredis, host: ENV.fetch("EVALUATOR_REDIS_CACHE_HOST", "localhost"),
    port: ENV.fetch("EVALUATOR_REDIS_CACHE_PORT", 6379), db: ENV.fetch("EVALUATOR_REDIS_CACHE_DB", 0),
    inherit_socket: true)

    config.messaging_redis = Redis.new(driver: :hiredis, host: ENV.fetch("EVALUATOR_REDIS_MESSAGING_HOST", "localhost"),
                  port: ENV.fetch("EVALUATOR_REDIS_MESSAGING_PORT", 6379), db: ENV.fetch("EVALUATOR_REDIS_MESSAGING_DB", 2),
                  inherit_socket: true)
    config.cache_store = :redis_cache_store, {redis: config.redis, compress: true, compress_threshold: 1.kilobytes}
    Sidekiq.configure_server do |sq|
      sq.redis = ConnectionPool.new(size: 5) {config.messaging_redis}
    end
    
    Sidekiq.configure_client do |sq|
      sq.redis = ConnectionPool.new(size: 1) {config.messaging_redis}
    end  
  end
  config.create_redis_connections.call(config)
  
end
