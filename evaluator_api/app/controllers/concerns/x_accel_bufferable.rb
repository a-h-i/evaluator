module XAccelBufferable

  extend ActiveSupport::Concern
  def add_bufferable_header
    response.headers['X-Accel-Buffering'] = 'yes'
  end
end