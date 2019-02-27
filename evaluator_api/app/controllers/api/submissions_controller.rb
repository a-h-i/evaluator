class Api::SubmissionsController < ApplicationController
  include XAccelBufferable
  prepend_before_action :set_parent, only: [:create, :index]
  prepend_before_action :authenticate, :authorize
  before_action :can_view, only: [:show, :download]
  after_action :add_bufferable_header, only: [:download]
  after_action :no_cache, only: [:create, :destroy, :download]
  after_action :cull_and_run, only: [:create]

  

  def download
    options = {
      type: @submission.mime_type,
      disposition: "attachment",
      filename: @submission.created_at.strftime("%Y_%j_%H_%M_%S_%L") +  "_#{@submission.id}_#{@submission.file_name}",
    }
    send_file @submission.file_path, options
  end


  protected

  def cull_and_run
    @submission.cull
    @submission.evaluate
  end

  def base_index_query
    query = Submission.viewable_by_user(@current_user).where(project: @project)
    possible_user_fields = User.queriable_fields
    # A query based on user fields
    if params.key?(:submitter) &&
       user_params = params[:submitter].permit(possible_user_fields)
      query = query.joins(:submitter) unless user_params.empty?
      user_params.keys.each do |key|
        query = if key.to_s.in? ['email', 'name']
                  query.where("users.#{key} ILIKE ?", "%#{user_params[key]}%")
                else
                  query.where(users: { key => user_params[key] })
                end
      end
    end
    if params.key?(:team)
      query = query.where(team: params[:team])
    end
    query
  end

  def submission_params
    @permitted_params ||= params_helper
  end

  def set_parent
    @project ||= Project.cache_fetch({id: params[:project_id]}) {Project.find params[:project_id]}
  end

  def can_view
    unless @submission.is_viewable_by? @current_user
      raise ForbiddenError, error_messages[:forbidden]
    end
  end

  def params_helper
    attributes = model_attributes << :file
    attributes.delete :id
    attributes.delete :project_id
    attributes.delete :solution_id
    attributes.delete :submitter_id
    permitted = params.permit attributes
    inferred = {
      submitter: @current_user
    }
    inferred[:project] = @project unless @project.nil?
    permitted.merge inferred
  end
  def order_args
    { created_at: :desc }
  end
end
