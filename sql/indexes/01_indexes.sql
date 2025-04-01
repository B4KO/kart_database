-- Audit log indexes
CREATE INDEX idx_table_record ON audit_log(table_name, record_id);
CREATE INDEX idx_changed_at ON audit_log(changed_at);

-- Organization indexes
CREATE INDEX idx_owner_type ON organizations(owner_type_id);

-- Address indexes
CREATE INDEX idx_location ON addresses(city, county, country);

-- Contact indexes
CREATE INDEX idx_name ON contacts(name);

-- Project indexes
CREATE INDEX idx_department ON projects(department_id);
CREATE INDEX idx_owner ON projects(owner_id);
CREATE INDEX idx_status ON projects(status_id);
CREATE INDEX idx_dates ON projects(start_date, end_date);
CREATE INDEX idx_active ON projects(is_active);
CREATE INDEX idx_projects_title ON projects(title);

-- Project organization indexes
CREATE INDEX idx_organization ON project_organizations(organization_id);

-- Backup history indexes
CREATE INDEX idx_backup_history_status ON backup_history(status);
CREATE INDEX idx_backup_history_dates ON backup_history(start_time, end_time); 