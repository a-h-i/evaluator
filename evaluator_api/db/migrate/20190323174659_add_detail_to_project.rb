class AddDetailToProject < ActiveRecord::Migration[5.2]
  def change
    Project.transaction do
      execute <<-SQL
      ALTER TABLE projects ADD COLUMN detail json;
      SQL
      Project.all.each do |project|
          project.detail = {
            spec_type: Project::JAVA_8_SPEC_TYPE,
            spec_subtype: Project::JUNIT_4_SUB_TYPE,
            dependencies: [] 
          }
          project.save
      end
      execute <<-SQL
        ALTER TABLE projects ALTER COLUMN detail SET NOT NULL;
      SQL
    end
  end
end
