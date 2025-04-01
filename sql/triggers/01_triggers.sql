-- Triggers for updating timestamps
CREATE TRIGGER update_owner_types_updated_at
    BEFORE UPDATE ON owner_types
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_organizations_updated_at
    BEFORE UPDATE ON organizations
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_departments_updated_at
    BEFORE UPDATE ON departments
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_project_status_updated_at
    BEFORE UPDATE ON project_status
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_digital_networks_updated_at
    BEFORE UPDATE ON digital_networks
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_addresses_updated_at
    BEFORE UPDATE ON addresses
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_contacts_updated_at
    BEFORE UPDATE ON contacts
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_projects_updated_at
    BEFORE UPDATE ON projects
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_project_organizations_updated_at
    BEFORE UPDATE ON project_organizations
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Trigger for backup failure alerts
CREATE TRIGGER trg_backup_failure_alert
    AFTER INSERT ON backup_history
    FOR EACH ROW
    EXECUTE FUNCTION alert_backup_failure(); 