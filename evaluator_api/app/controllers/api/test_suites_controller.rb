class Api::TestSuitesController < ApplicationController
  include XAccelBufferable
  prepend_before_action :set_parent, only: [:create, :index]
  prepend_before_action :authenticate
  before_action :authorize_super_user, only: [:create, :destroy]
  before_action :can_access, only: [:show, :download]
  after_action :add_bufferable_header, only: [:download]
  after_action :no_cache, only: [:create, :destroy, :download]

  def download
    options = {
      type: @test_suite.mime_type,
      disposition: "attachment",
      filename: @test_suite.file_name
    }
    send_file @test_suite.file_path, options
  end

  protected

  def base_index_query
    query = TestSuite.viewable_by_user(@current_user).where(project_id: @project.id)
  end

  def can_access
    unless @test_suite.is_viewable_by? @current_user
      raise ForbiddenError, error_messages[:forbidden]
    end
  end

  def order_args
    { created_at: :desc }
  end

  
  def params_helper
    attributes = model_attributes << :file
    attributes.delete :id
    attributes.delete :project_id
    attributes.delete :project
    permitted = params.permit attributes
    permitted[:project] = @project unless @project.nil?
    permitted[:detail] = params.require(:detail).permit(:package_name)
    permitted
  end

  def test_suite_params
    @permitted_params ||= params_helper
  end

  def set_parent
    @project ||= Project.cache_fetch({id: params[:project_id]}) { Project.find params[:project_id] }
  end
end
