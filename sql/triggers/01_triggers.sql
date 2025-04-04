-- Function to handle audit logging
CREATE OR REPLACE FUNCTION audit_log_changes()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'DELETE' THEN
        INSERT INTO audit_log (
            table_name,
            record_id,
            action_type,
            changed_by,
            old_values
        ) VALUES (
            TG_TABLE_NAME,
            OLD.id,
            'DELETE',
            current_user,
            row_to_json(OLD)
        );
        RETURN OLD;
    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO audit_log (
            table_name,
            record_id,
            action_type,
            changed_by,
            old_values,
            new_values
        ) VALUES (
            TG_TABLE_NAME,
            NEW.id,
            'UPDATE',
            current_user,
            row_to_json(OLD),
            row_to_json(NEW)
        );
        RETURN NEW;
    ELSIF TG_OP = 'INSERT' THEN
        INSERT INTO audit_log (
            table_name,
            record_id,
            action_type,
            changed_by,
            new_values
        ) VALUES (
            TG_TABLE_NAME,
            NEW.id,
            'INSERT',
            current_user,
            row_to_json(NEW)
        );
        RETURN NEW;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Function to validate project dates
CREATE OR REPLACE FUNCTION validate_project_dates()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.end_year IS NOT NULL AND NEW.end_year < NEW.start_year THEN
        RAISE EXCEPTION 'End year cannot be earlier than start year';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Function to ensure email format
CREATE OR REPLACE FUNCTION validate_email_format()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.email !~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$' THEN
        RAISE EXCEPTION 'Invalid email format';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Function to prevent deletion of active projects
CREATE OR REPLACE FUNCTION prevent_active_project_deletion()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.status = 'IN_PROGRESS' THEN
        RAISE EXCEPTION 'Cannot delete active projects';
    END IF;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

-- Create triggers for audit logging
CREATE TRIGGER audit_projects
    AFTER INSERT OR UPDATE OR DELETE ON projects
    FOR EACH ROW
    EXECUTE FUNCTION audit_log_changes();

CREATE TRIGGER audit_owners
    AFTER INSERT OR UPDATE OR DELETE ON owners
    FOR EACH ROW
    EXECUTE FUNCTION audit_log_changes();

CREATE TRIGGER audit_contacts
    AFTER INSERT OR UPDATE OR DELETE ON contacts
    FOR EACH ROW
    EXECUTE FUNCTION audit_log_changes();

-- Create trigger for project date validation
CREATE TRIGGER validate_project_dates_trigger
    BEFORE INSERT OR UPDATE ON projects
    FOR EACH ROW
    EXECUTE FUNCTION validate_project_dates();

-- Create trigger for email format validation
CREATE TRIGGER validate_email_format_trigger
    BEFORE INSERT OR UPDATE ON contacts
    FOR EACH ROW
    EXECUTE FUNCTION validate_email_format();

-- Create trigger to prevent deletion of active projects
CREATE TRIGGER prevent_active_project_deletion_trigger
    BEFORE DELETE ON projects
    FOR EACH ROW
    EXECUTE FUNCTION prevent_active_project_deletion();

-- Function to update project status based on dates
CREATE OR REPLACE FUNCTION update_project_status()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.end_year IS NOT NULL AND NEW.end_year <= EXTRACT(YEAR FROM CURRENT_DATE) THEN
        NEW.status := 'COMPLETED'::project_status;
    ELSIF NEW.start_year <= EXTRACT(YEAR FROM CURRENT_DATE) THEN
        NEW.status := 'IN_PROGRESS'::project_status;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to automatically update project status
CREATE TRIGGER update_project_status_trigger
    BEFORE INSERT OR UPDATE ON projects
    FOR EACH ROW
    EXECUTE FUNCTION update_project_status();

-- Function to ensure unique project titles within the same sector
CREATE OR REPLACE FUNCTION validate_unique_project_title()
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM projects 
        WHERE title = NEW.title 
        AND sector = NEW.sector 
        AND id != NEW.id
    ) THEN
        RAISE EXCEPTION 'Project title must be unique within the same sector';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for unique project titles
CREATE TRIGGER validate_unique_project_title_trigger
    BEFORE INSERT OR UPDATE ON projects
    FOR EACH ROW
    EXECUTE FUNCTION validate_unique_project_title(); 