class Api::CoursesController < ApplicationController
  prepend_before_action :authorize_teacher, only: [:destroy, :update, :create]
  prepend_before_action :authenticate
  before_action :hide_unpublished, only: [:index]
  before_action :hide_unpublished_single, only: [:show]
  before_action :must_be_published, only: [:register, :unregister]
  before_action :authorize_student, only: [:register, :unregister]



  def register
    get_resource.register @current_user
    render json: {message: messages[:registration_success]}, status: :created
  end

  def unregister
    get_resource.unregister @current_user
    render json: {message: messages[:unregistration_success]}
  end


  private

  def hide_unpublished
    params[:published] = true if @current_user.student?
  end

  def hide_unpublished_single
    if @current_user.student? && !get_resource.published?
      raise ForbiddenError, error_messages[:forbidden_teacher_only]
    end
  end

  def must_be_published
    raise ForbiddenError, error_messages[:forbidden] unless get_resource.published?
  end

  def query_params
    params.permit(:name, :published)
  end

  def course_params
    attributes = model_attributes
    attributes.delete :id
    params.permit attributes
  end


end