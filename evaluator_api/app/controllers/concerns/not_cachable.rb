module NotCachable
  extend ActiveSupport::Concern
  included do
    after_action :no_cache, only: [:create, :destroy, :update]
  end

  protected
  
  def no_cache
    response.headers['Cache-Control'] = 'no-cache, no-store, must-revalidate' # HTTP 1.1.
    response.headers['Pragma'] = 'no-cache' # HTTP 1.0.
    response.headers['Expires'] = '0' # Proxies.
  end
end
