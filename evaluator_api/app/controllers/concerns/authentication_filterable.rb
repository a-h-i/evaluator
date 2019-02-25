=begin
Authorization logic for controllers
by default only adds authenticate and authorize for destroy and update
authenticated user is @current user
=end
module AuthenticationFilterable
  extend ActiveSupport::Concern

  protected

  # To be overriden by subclasses
  # in order to perform role checks
  def user_authorized
    true
  end

  # Set Header and response
  def prepare_unauthorized_response
    response.headers['WWW-Authenticate'] = 'Token realm="Evaluator"'
    response.status = :unauthorized
  end

  def authorize
    raise ForbiddenError, error_messages[:forbidden] unless user_authorized
  end

  # Optional teacher only authorization
  def authorize_teacher
    raise ForbiddenError, error_messages[:forbidden_teacher_only] unless
      @current_user.teacher?
  end

  # Optional super user only authorization
  def authorize_super_user
    raise ForbiddenError, error_messages[:forbidden_super_user_only] unless
      @current_user.super_user?
  end

  # Optional student only
  def authorize_student
    raise ForbiddenError, error_messages[:forbidden_student_only] unless
      @current_user.student?
  end


  # Attempts to set current user
  def authenticate
    pattern = /^Bearer /
    header  = request.headers['Authorization']
    if header && header.match(pattern)
      token = header.gsub(pattern, '')
      @current_user = User.find_by_token token
      raise ForbiddenError, error_messages[:unverified_login] unless @current_user.verified?
    else
      raise AuthenticationError
    end
  rescue ActiveRecord::RecordNotFound
    raise AuthenticationError
  end

  def authenticate_optional
    authenticate
  rescue
    false
  end


end
