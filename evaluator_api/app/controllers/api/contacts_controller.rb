class Api::ContactsController < ApplicationController
  before_action :authenticate_optional

  private

  def contact_params
    data = params.permit(:text, :reported_at, :title)
    data[:user] = @current_user if @current_user.present?
    data
  end
end
