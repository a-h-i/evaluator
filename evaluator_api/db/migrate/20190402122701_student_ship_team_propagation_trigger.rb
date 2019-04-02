class StudentShipTeamPropagationTrigger < ActiveRecord::Migration[5.2]
  def up

    execute <<-SQL
    CREATE FUNCTION propagate_team() RETURNS trigger AS $$
    BEGIN
      IF TG_OP = 'DELETE' THEN
        UPDATE submissions SET team = NULL WHERE submitter_id = OLD.student_id AND course_id = OLD.course_id;
      ELSIF TG_OP = 'INSERT' OR (TG_OP = 'UPDATE' AND OLD.team IS DISTINCT FROM NEW.team) THEN
        UPDATE submissions SET team = NEW.team WHERE submitter_id = NEW.student_id AND course_id = NEW.course_id;
      END IF;
      RETURN NULL;
    END;
    $$ LANGUAGE plpgsql
    VOLATILE;

    CREATE TRIGGER team_propagation_trigger 
    AFTER DELETE OR UPDATE OR INSERT
    ON student_course_registrations
    FOR EACH ROW EXECUTE PROCEDURE propagate_team();
    SQL
  end

  def down
    execute <<-SQL

    DROP TRIGGER IF EXISTS team_propagation_trigger ON student_course_registrations RESTRICT;
    DROP FUNCTION IF EXISTS propagate_team() RESTRICT;
    SQL
  end
end
