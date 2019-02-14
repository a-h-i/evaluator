class TokensController < ApplicationController
  def create
    opts = token_params
    user = User.login(opts[:email], opts[:password])
    render json: {
      token: user.token(opts[:expiration]),
      user: user
    }, status: :created
  end

  def token_params
    params.require(:token).permit([:email, :password, :expiration])
  end
end
