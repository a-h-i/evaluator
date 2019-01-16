# Implements basic find caching and cache utility methods
# Caches in redis
module Cacheable
  extend ActiveSupport::Concern

  module ClassMethods
    def related_set_name(id)
      "#{table_name.singularize}_#{id}_related_keys"
    end

    def add_related_cache(id, key)
      $redis.sadd related_set_name(id), key
    end

    def attribute_cache_key(attr_name, value)
      "#{table_name.singularize}_#{attr_name}_#{value}"
    end

    def cache_key(id)
      "#{table_name.singularize}_#{id}"
    end

    def hash_to_key(hash)
      hash.each_pair.reduce('') do |a, e|
        value = e.second
        value = hash_to_key(e.second) if e.second.is_a? Hash
        "#{a}&#{e.first}=#{value}"
      end
    end

    def find_by(*opts)
      key = "#{table_name.singularize}_opts_#{hash_to_key(*opts)}"
      cached = $redis.get key
      if cached.nil?
        record = method(:find_by).super_method.call(*opts)
        $redis.set key, Marshal.dump(record) if record.present?
        add_related_cache(record.id, key) if record.present?
        record
      else
        Marshal.load(cached)
      end
    end

    def find_one_cache(id)
      id = id.id if ActiveRecord::Base === id
      cached = $redis.get cache_key(id)
      if cached.nil?
        record = method(:find).super_method.call id
        $redis.set cache_key(id), Marshal.dump(record)
        record
      else
        Marshal.load(cached)
      end
    end

    def find_helper(*ids)
      expects_array = ids.first.is_a?(Array)
      return ids.first if expects_array && ids.first.empty?

      ids = ids.flatten.compact.uniq

      case ids.size
      when 0
        raise ActiveRecord::RecordNotFound, "Couldn't find #{self.name} without an ID"
      when 1
        result = find_one_cache(ids.first)
        expects_array ? [result] : result
      else
        method(:find).super_method.call ids
      end
    end

    def find(*args)
      record = find_helper(*args)
    end
  end

  included do
    after_destroy :destroy_id_cache, :destroy_related_caches
    after_update :destroy_id_cache, :destroy_related_caches
  end

  def destroy_related_caches
    keys = $redis.smembers self.class.related_set_name(id)
    return if keys.nil?
    $redis.pipelined do
      keys.each { |k| $redis.del k }
    end
    $redis.del self.class.related_set_name(id)
  end

  def destroy_id_cache
    $redis.del self.class.cache_key(id)
  end
end
