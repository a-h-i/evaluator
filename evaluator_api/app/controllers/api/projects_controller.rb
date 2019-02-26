class Api::ProjectsController < ApplicationController
  prepend_before_action :set_parent, only: [:create, :index]
  prepend_before_action :authorize_teacher, :authorize_super_user,
                        only: [:destroy, :update, :create]
  prepend_before_action :authenticate
  before_action :hide_unpublished, only: [:index]
  before_action :hide_unpublished_single, only: [:show]

  private

  # Prevent students from viewing unpublsihed projects
  # Or any projects belonging to an unpublished course
  def hide_unpublished_single
    unless @project.viewable_by_user? @current_user
      raise ForbiddenError, error_messages[:forbidden_teacher_only]
    end
  end

  # Prevent students from viewing unpublsihed projects
  # Or any projects belonging to an unpublished course
  def hide_unpublished
    if @current_user.student?
      raise ForbiddenError if !@course.published?
      params[:published] = true
      params[:registered] = true
    end
  end

  def set_parent
    @course ||= Course.cache_fetch(id: params[:course_id]) { Course.find params[:course_id] }
  end

  def query_params
    params.permit(:name, :published, :registered)
  end

  def project_params
    @permitted_params ||= params_helper
  end

  def params_helper
    attributes = model_attributes
    attributes.delete :id
    attributes.delete :course_id
    attributes.delete :reruning_submissions unless @current_user.super_user?
    permitted = params.permit attributes
    permitted[:course] = @course unless @course.nil?
    permitted
  end

  def apply_query(base, query_params)
    
    if query_params[:name].present?
      base = base.where("name ILIKE ?", "%#{query_params[:name]}%")
    end
    if query_params[:published].present?
      base = base.where(published: query_params[:published])
    end
    if query_params[:registered].present?
      base = base.joins('INNER JOIN student_course_registrations ON student_course_registrations.course_id = projects.course_id').where(courses: {student_course_registrations: {student_id: @current_user.id}})
    end
    base
  end

  def order_args
    if query_params[:name].present?
      "length(projects.name) ASC"
    else
      { created_at: :desc }
    end
  end

  def base_index_query
    base = Project.where(course: @course)
    base = params[:due].to_s == 'true' ? base.due : base.not_due unless params[:due].nil?
    base = base.started if params[:started]
    return base
  end
end
