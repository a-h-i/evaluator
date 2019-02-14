module Cachable
  extend ActiveSupport::Concern

  module ClassMethods
    def get_cache_key(*params)
      ActiveSupport::Cache.expand_cache_key(params, table_name)  
    end
  end

  # TODO: Implement cache fetch, read, write and cleanup after updates
end