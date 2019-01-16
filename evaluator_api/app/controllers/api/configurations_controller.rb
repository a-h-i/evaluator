class Api::ConfigurationsController < ApplicationController
  def index
    configurations = Rails.application.config.configurations
    render json: Rails.application.config.configurations if stale?(
      configurations.to_json, template: false)
  end
end
