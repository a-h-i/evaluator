namespace :submissions do
  desc "Migrates submissions from top level folder to submissions folder"
  task migrate: :environment do
    submissions_path = Rails.application.config.submissions_path
    parent_directory = File.expand_path('..', submissions_path)
    regex = /submissions[0-9]+_.+/
    submission_files = Dir.entries(parent_directory).select { |file_name| file_name === regex }
    submission_files.each do |file|
      old_path = File.join parent_directory, file
      new_file_name = file.sub /submissions/, ''
      new_path = File.join parent_directory, new_file_name
      FileUtils.mv old_path, new_path
    end
  end

end
