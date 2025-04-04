-- Indexes for projects table
CREATE INDEX idx_projects_status ON projects(status);
CREATE INDEX idx_projects_sector ON projects(sector);
CREATE INDEX idx_projects_start_year ON projects(start_year);
CREATE INDEX idx_projects_end_year ON projects(end_year);
CREATE INDEX idx_projects_management_level ON projects(managment_level);
CREATE INDEX idx_projects_title ON projects(title);

-- Indexes for projects_owners junction table
CREATE INDEX idx_projects_owners_project_id ON projects_owners(project_id);
CREATE INDEX idx_projects_owners_owner_id ON projects_owners(owner_id);

-- Indexes for projects_contacts junction table
CREATE INDEX idx_projects_contacts_project_id ON projects_contacts(project_id);
CREATE INDEX idx_projects_contacts_contact_id ON projects_contacts(contact_id);

-- Indexes for projects_locations junction table
CREATE INDEX idx_projects_locations_project_id ON projects_locations(project_id);
CREATE INDEX idx_projects_locations_location_id ON projects_locations(location_id);

-- Indexes for projects_cooperators junction table
CREATE INDEX idx_projects_cooperators_project_id ON projects_cooperators(project_id);
CREATE INDEX idx_projects_cooperators_cooperator_id ON projects_cooperators(cooperator_id);

-- Indexes for projects_benefits junction table
CREATE INDEX idx_projects_benefits_project_id ON projects_benefits(project_id);
CREATE INDEX idx_projects_benefits_benefit_id ON projects_benefits(benefit_id);

-- Indexes for owners table
CREATE INDEX idx_owners_name ON owners(name);

-- Indexes for contacts table
CREATE INDEX idx_contacts_name ON contacts(name);
CREATE INDEX idx_contacts_email ON contacts(email);

-- Indexes for cooperators table
CREATE INDEX idx_cooperators_name ON cooperators(name);

-- Indexes for benefits table
CREATE INDEX idx_benefits_name ON benefits(name);

-- Indexes for addresses table
CREATE INDEX idx_addresses_city ON addresses(city);
CREATE INDEX idx_addresses_county ON addresses(county);
CREATE INDEX idx_addresses_postal_code ON addresses(postal_code);

-- Indexes for audit log
CREATE INDEX idx_audit_log_table_name ON audit_log(table_name);
CREATE INDEX idx_audit_log_record_id ON audit_log(record_id);
CREATE INDEX idx_audit_log_action_type ON audit_log(action_type);
CREATE INDEX idx_audit_log_changed_at ON audit_log(changed_at);

-- Composite indexes for common query patterns
CREATE INDEX idx_projects_status_sector ON projects(status, sector);
CREATE INDEX idx_projects_start_end_year ON projects(start_year, end_year);
CREATE INDEX idx_projects_management_status ON projects(managment_level, status);
CREATE INDEX idx_projects_sector_status_year ON projects(sector, status, start_year);

-- Full text search indexes
CREATE INDEX idx_projects_description_fts ON projects USING gin(to_tsvector('english', description));
CREATE INDEX idx_projects_notes_fts ON projects USING gin(to_tsvector('english', notes));
CREATE INDEX idx_benefits_description_fts ON benefits USING gin(to_tsvector('english', description)); 