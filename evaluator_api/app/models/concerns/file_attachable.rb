module FileAttachable
  extend ActiveSupport::Concern

  included do
    before_save :file_attachable_before_save_callback
    after_commit :file_attachable_after_commit_callback
  end
  attr_accessor :file_attachable_storage_file_object
  def file_attachable_reset_storage
    @file_attachable_storage_ops = []
  end
  
  def get_transaction_operation
    if transaction_include_any_action? [:update]
      :update
    elsif transaction_include_any_action? [:create]
      :create
    else
      :destory
    end
  end

  def file_attachable_after_commit_callback
    operation = get_transaction_operation
    @file_attachable_storage_ops.each { |func| func.call(operation) }
  end



  def file_attachable_before_save_callback
    file_attachable_reset_storage
    # if there was an old filename, we need to move the file once commited 
    if persisted?
      return unless file_name_changed?
      old_name = file_name_was.dup
      new_name = file_name
      @file_attachable_storage_ops.push Proc.new do |operation|
        case operation
        when :update
          move_file(get_file_path(old_name), get_file_path(new_name))
        when :destroy
          remove_file(get_file_path(old_name))
        end
      end
    else
      # New file
      @file_attachable_storage_ops.push Proc.new { | operation |save_file(get_file_path(file_name), file_attachable_storage_file_object) if operation.eql? :create }

    end
  end
  def remove_file(path)
    FileUtils.rm_f [path]
  end

  def move_file(old_path, new_path)
    FileUtils.mv old_path, new_path
  end

  def save_file(path, file_object)
    file = File.open(path, 'wb')
    IO.copy_stream(file_object, path)
    file.close
  end

  def file=(val)
    self.file_attachable_storage_file_object = val
    self.file_name = if val.respond_to? :original_filename
       val.original_filename
    elsif val.respond_to? :filename
      val.filename
    else
      File.basename(val.path)
    end
      self.mime_type =  if val.respond_to? :content_type
      val.content_type
    else
      'application/binary'
    end
    file
  end

  def file
    self.file_attachable_storage_file_object
  end
  
end