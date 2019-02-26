class Api::SubmissionsController < ApplicationController
  prepend_before_action :set_parent, only: [:create, :index]
  prepend_before_action :authenticate, :authorize
  before_action :can_view, only: [:show, :download]
end


def download
  solution = @submission.solution
  options = {
    type: @submission.mime_type,
    disposition: 'attachment',
    filename: @submission.created_at.strftime("%Y_%j_%H_%M_%S_%L") + @submission.file_name
  }
  send_file @submission.code_path, options
end