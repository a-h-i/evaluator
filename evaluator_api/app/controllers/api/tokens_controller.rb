class Api::TokensController < ApplicationController

  def create
    user = User.login(token_params[:email], token_params[:password])
    render json: {
      token: user.token(token_params[:expiration]),
      user: user,
    }, status: :created
  end

  private

  def authenticate_user(user)
    raise AuthenticationError if user.nil?
    raise AuthenticationError unless user.authenticate?(token_params[:password])
    raise ForbiddenError, error_messages[:unverified_login] unless
      user.verified?
  end

  def token_params
    params.require(:token).permit([:email, :password, :expiration])
  end
end
