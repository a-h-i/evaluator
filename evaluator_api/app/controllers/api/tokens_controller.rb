class Api::TokensController < ApplicationController

  def create
    find_hash = {email: token_params[:email].downcase}
    user = User.cache_fetch(find_hash) do
      User.find_by(find_hash)
    end
    authenticate_user(user)
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
