module ZipFile
  extend ActiveSupport::Concern
  included do
    validate :code_exists
    validate :file_type
    before_save :sanitize_own_file_name
  end

  def code_exists
    errors.add(:code, 'can not be blank') if code.nil? || code.size == 0
  end

  def file_type
    if file_name.present? && File.extname(file_name) != '.zip'
      errors.add(:file_name, 'must be a zip file')
    end
  end

  def sanitize_filename(filename)
    # Split the name when finding a period which is preceded by some
    # character, and is followed by some character other than a period,
    # if there is no following period that is followed by something
    # other than a period (yeah, confusing, I know)
    fn = filename.split /(?<=.)\.(?=[^.])(?!.*\.[^.])/m

    # We now have one or two parts (depending on whether we could find
    # a suitable period). For each of these parts, replace any unwanted
    # sequence of characters with an underscore
    fn.map! { |s| s.gsub /[^a-z0-9\-]+/i, '_' }

    # Finally, join the parts with a period and return the result
    fn.join '.'
  end

  def sanitize_own_file_name
    self.file_name = sanitize_filename file_name
  end
end
