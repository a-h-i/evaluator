$redis_client = Redis.new(driver: :hiredis)

$redis = Redis::Namespace.new('evaluator', redis: $redis_client,
                                           deprecations: true)


redis_resque_client = Redis.new(drive: :hiredis, db: 3)
# TODO: Seperate redis servers
Resque.redis = redis_resque_client                                        