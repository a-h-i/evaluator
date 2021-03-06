class Api::UsersController < ApplicationController
  prepend_before_action :get_by_email, only: [:reset_password, :resend_verify]
  prepend_before_action :authenticate, only: [:index, :show, :update, :destroy]
  before_action :authorize_super_user, only: [:destroy]
  before_action :authorize_teacher, only: [:index]
  before_action :authorize, only: [:index, :show, :update]
  after_action :no_cache, except: [:index, :show]
  after_action :send_verification, only: [:create]
  skip_before_action :set_resource, only: [:reset_password, :resend_verify, :confirm_reset, :verify]
  # Requests a password reset
  def reset_password
    @user.send_reset_pass_email
    head :no_content
  end

  # Confirm password reset
  # Expects reset token field in query
  def confirm_reset
    
    new_pass = params[:password]
    token = params[:token]
    if User.confirm_reset token, new_pass
      head :no_content
    else
      render json: {message: error_messages[:incorrect_reset_token]},
             status: :unprocessable_entity
    end
  end

  def show
    raise ForbiddenError, error_messages[:forbidden_teacher_only] unless @current_user.id == get_resource.id || @current_user.teacher?
    super
  end

  def resend_verify
    if !@user.verified?
      send_verification
      head :no_content
    else
      render json: {message: error_messages[:already_verified]},
             status: :bad_request
    end
  end

  # Verifies user account
  # Expects token to be present as token field in query
  def verify
    token = params[:token]
    @user = User.verify token
    if @user
      render json: {
        data: {
          token: @user.token,
          user: @user,
        },
      }
    else
      render json: {message: error_messages[:incorrect_verification_token]},
             status: :unprocessable_entity
    end
  end

  private

  def query_params
    params.permit(:student, :super_user, :name, :email, :guc_suffix,
                  :guc_prefix)
  end

  def apply_query(base, query_params)
    if query_params[:name].present?
      base = base.where("name ILIKE ?", "%#{query_params[:name]}%")
    end
    if query_params[:email].present?
      base = base.where("email ILIKE ? ", "%#{query_params[:email]}%")
    end
    query_params.delete :email
    query_params.delete :name
    base.where(query_params)
  end

  def order_args
    if query_params[:name].present?
      "length(users.name) ASC"
    elsif query_params[:email].present?
      "length(users.email) ASC"
    elsif query_params[:team].present?
      "length(users.team) ASC"
    else
      :created_at
    end
  end

  def user_params
    attributes = model_attributes
    attributes.delete :password_digest
    attributes.delete :id
    attributes.delete :student
    unless @current_user.present? && @current_user.super_user? 
      attributes.delete :super_user
      attributes.delete :verified
      attributes.delete :verified_teacher
    end
    
    data = params.permit attributes << :password
    data
  end

  def send_verification
    @user.send_verification_email
  end

  def user_authorized
    return true if @current_user.present? && @current_user.super_user?
    return true if @user.present? && @current_user.present? && @current_user.id == @user.id
    @current_user.present? && @current_user.teacher? && [:show, :index].include?(action_name.to_sym)
  end

  def get_by_email
    @user = User.find_by_email! Base64.urlsafe_decode64(params[:email]).downcase
  end
end
