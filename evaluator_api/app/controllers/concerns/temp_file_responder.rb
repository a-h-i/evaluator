module TempFileResponder
  extend ActiveSupport::Concern

  protected

  def send_temp_file(file, filename, ext, close=true)
    options = {
      type: Rack::Mime.mime_type('.csv'),
      disposition: 'attachment',
      filename: filename
    }
    file.rewind
    send_data file.read, **options
    file.close if close
    file.unlink if close
  end
end
