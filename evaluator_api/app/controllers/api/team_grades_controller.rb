class Api::TeamGradesController < ApplicationController
  prepend_before_action :set_parent, except: [:show, :destroy]
  before_action :set_resource, only: []
  before_action :authorize_student, only: [:latest]
  prepend_before_action :authenticate

  def latest
    render json: @current_user.team_grades.where(project: @project)
      .order(created_at: :desc).take!
  end

  private

  def set_parent
    @project ||= Project.find params[:project_id]
  end
end
