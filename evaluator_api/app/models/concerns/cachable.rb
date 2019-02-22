#
# Classes wishing to do their own cache serialization
# should implement class serialize_cache
# and class method deserialize_cache
# Should not be using an [id, :related_cache_keys] as a key since that is reserved 
module Cachable
  extend ActiveSupport::Concern

  module ClassMethods

    # Converts key params to key string
    # Should be used when reading/writing with non string keys
    def expand_cache_key(*params)
      ActiveSupport::Cache.expand_cache_key(params)  
    end

    def cache_fetch(key, **opts)
      val = cache_read(key, opts)
      return val unless val.nil?
      val = yield
      cache_write(key, val, opts)
    end
  
    def cache_read(key, **opts)      
      val = redis.get normalize_key(key)
      deserialize_cache(val)
    end
  
    def cache_write(key, value, **opts)
      normalized_key = normalize_key(key)
      serialized_value = serialize_cache(value)
      redis.set normalized_key, serialized_value
      redis.expire(normalized_key, opts[:expires_in]) if opts.has_key? :expires_in
      value
    end

    def normalize_key(key)
      expand_cache_key [table_name, key]
    end

  
    def redis
      Rails.application.config.redis
    end

    def serialize_cache(val)
      val.nil? ? val : Marshal.dump(val)
    end
    def deserialize_cache(val)
      val.nil? ? val : Marshal.load(val) 
    end
  end

  
  def add_related_cache_key(key)
    val = self.class.normalize_key(key)
    redis.rpush related_cache_list_key, val
  end

  def invalidate_related_keys
    id_key = self.class.normalize_key({id: id})
    redis.unlink id_key
    list_key = related_cache_list_key

    loop do
      redis.watch list_key
      keys = redis.lrange list_key, 0, -1
      redis.multi
      keys.each {|key| redis.unlink key}
      redis.unlink list_key
      exec_val = redis.exec
      break unless exec_val.nil?
    end

  end
  
  def related_cache_list_key
    self.class.normalize_key [id, :related_cache_keys]
  end

  def redis
    self.class.redis
  end

  included do
    after_commit :invalidate_related_keys, on: [:update]
  end
  
end