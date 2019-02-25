class Api::ConfigurationsController < ApplicationController
  def index
    if stale?(last_modified: Rails.application.config.configuration_last_modified_at, 
      etag: Rails.application.config.configurations_digest)
      render json: Rails.application.config.configurations
    end
  end
end
