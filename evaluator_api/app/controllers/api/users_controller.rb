class Api::UsersController < ApplicationController
  prepend_before_action :authenticate, only: [:index, :show, :update, :destroy]
  before_action :authorize_super_user, only: [:destroy]
  before_action :authorize_teacher, only: [:index]
  after_action :no_cache, except: [:index, :show]
  after_action :reload_resource, only: [:create]
  after_action :send_verification, only: [:create]
  skip_before_action :set_resource, only: [:reset_password, :resend_verify]
  before_action :get_by_email, only: [:reset_password, :resend_verify]

  # Requests a password reset
  def reset_password
    if @user.can_resend_reset?
      UserMailer.pass_reset_email(@user).deliver_later
      head :no_content
    else
      render json: { message: error_messages[:too_soon] }, status: 420
    end
  end

  # Confirm password reset
  # Expects reset to be present as token field in query
  def confirm_reset
    new_pass = params[:pass]
    token = params[:token]
    if @user.reset_password token, new_pass
      head :no_content
    else
      render json: { message: error_messages[:incorrect_reset_token] },
             status: :unprocessable_entity
    end
  end

  def show
    raise ForbiddenError, error_messages[:forbidden_teacher_only] unless @current_user.id == get_resource.id || @current_user.teacher?
    super
  end

  def resend_verify
    if !@user.verified?
      if @user.can_resend_verify?
        send_verification
        head :no_content
      else
        render json: { message: error_messages[:too_soon] }, status: 420
      end
    else
      render json: { message: error_messages[:already_verified] },
             status: :bad_request
    end
  end

  # Verifies user account
  # Expects token to be present as token field in query
  def verify
    token = params[:token]
    if @user.verify token
      render json: {
        data: {
          token: @user.token,
          user: @user
        }
      }
    else
      render json: { message: error_messages[:incorrect_verification_token] },
             status: :unprocessable_entity
    end
  end

  private

  def query_params
    params.permit(:student, :super_user, :name, :email, :guc_suffix,
                  :guc_prefix, :team)
  end

  def apply_query(base, query_params)
    if query_params[:name].present?
      base = base.where('name ILIKE ?', "%#{query_params[:name]}%")
    end
    if query_params[:email].present?
      base = base.where('email ILIKE ? ', "%#{query_params[:email]}%")
    end
    if query_params[:team].present?
      base = base.where('team ILIKE ? ', "%#{query_params[:team]}%")
    end
    query_params.delete :email
    query_params.delete :name
    query_params.delete :team
    base.where(query_params)
  end

  def order_args
    if query_params[:name].present?
      'length(users.name) ASC'
    elsif query_params[:email].present?
      'length(users.email) ASC'
    elsif query_params[:team].present?
      'length(users.team) ASC'
    else
      :created_at
    end
  end

  def user_params
    attributes = model_attributes
    attributes.delete :password_digest
    attributes.delete :verified unless @current_user.present? &&
                                       @current_user.super_user?
    attributes.delete :id
    attributes.delete :student
    unless @current_user.present? && @current_user.super_user?
      attributes.delete :super_user
      attributes.delete :team
    end
    if @user.present? && !@current_user.super_user?
      # This is an update
      attributes.delete :guc_prefix
      attributes.delete :guc_suffix
    end
    data = params.permit attributes << :password
    data[:team] = '-1' if @user.nil?
    data
  end

  def reload_resource
    @user.reload if @user.persisted?
  end

  def send_verification
    UserMailer.verification_email(@user).deliver_later if @user.persisted?
  end

  def user_authorized
    @current_user.id == @user.id || @current_user.super_user?
  end

  def get_by_email
    @user = User.find_by_email! Base64.decode64(params[:email])
  end
end
