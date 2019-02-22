

Rails.application.configure do
  config.redis = Redis.new(driver: :hiredis, host: ENV.fetch("EVALUATOR_REDIS_CACHE_HOST", "localhost"),
                           port: ENV.fetch("EVALUATOR_REDIS_CACHE_PORT", 6379), db: ENV.fetch("EVALUATOR_REDIS_CACHE_DB", 0),
                           inherit_socket: false)

  config.messaging_redis = Redis.new(driver: :hiredis, host: ENV.fetch("EVALUATOR_REDIS_MESSAGING_HOST", "localhost"),
                                     port: ENV.fetch("EVALUATOR_REDIS_MESSAGING_PORT", 6379), db: ENV.fetch("EVALUATOR_REDIS_MESSAGING_DB", 2),
                                     inherit_socket: false)
  config.action_controller.perform_caching = true
  config.cache_store = :redis_cache_store, {redis: config.redis, compress: true, compress_threshold: 1.kilobytes}
end
