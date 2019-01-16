class Api::TestSuitesController < ApplicationController
  prepend_before_action :set_parent, only: [:create, :index]
  before_action :can_view, only: [:show, :download]
  prepend_before_action :authorize_teacher, :authorize_super_user,
                        only: [:create, :destroy]
  prepend_before_action :authenticate, :authorize
  before_action :project_filter, only: [:index]
  before_action :destroyable, only: [:destroy]
  before_action :unpublished_only, only: [:create]

  def create
    TestSuite.transaction do
      @test_suite = TestSuite.new resource_params
      file = params.require(:file)
      @test_suite.name = File.basename(file.original_filename,
                                       File.extname(file.original_filename))
      if @test_suite.save
        code_params = {
          code: file.read,
          file_name: file.original_filename,
          mime_type: file.content_type,
          test_suite: @test_suite
        }
        code = SuiteCode.new code_params
        if code.save
          render json: @test_suite, status: :created
        else
          render json: code.errors, status: :unprocessable_entity
          raise ActiveRecord::Rollback
        end
      else
        render json: @test_suite.errors, status: :unprocessable_entity
        raise ActiveRecord::Rollback
      end
    end
    SuitesProcessJob.perform_later @test_suite if @test_suite.persisted?
  end

  def download
    code = @test_suite.suite_code
    options = {
      type: code.mime_type,
      disposition: 'attachment',
      filename: code.file_name
    }
    send_data code.code, **options
  end

  def destroy
    DestroyTestSuiteJob.perform_later @test_suite
    head :no_content
  end

  private

  def destroyable
    unless @test_suite.destroyable?
      raise ForbiddenError, error_messages[:forbidden]
    end
  end

  def unpublished_only
    raise ForbiddenError, error_messages[:forbidden] if @project.published?
  end

  def project_filter
    unless @current_user.can_view? @project
      raise ForbiddenError, error_messages[:forbidden_teacher_only]
    end
  end

  def params_helper
    attributes = model_attributes
    attributes.delete :id
    attributes.delete :project_id
    attributes.delete :ready
    attributes.delete :name
    permitted = params.permit attributes
    permitted[:project] = @project unless @project.nil?
    permitted
  end

  def test_suite_params
    @permitted_params ||= params_helper
  end

  def base_index_query
    TestSuite.viewable_by_user(@current_user).where(project: @project)
  end

  def set_parent
    @project ||= Project.find params[:project_id]
  end

  def can_view
    unless @current_user.can_view? @test_suite
      raise ForbiddenError, error_messages[:forbidden]
    end
  end
end
