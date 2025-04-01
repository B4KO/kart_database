-- Create audit log table for tracking changes
CREATE TABLE audit_log (
    id BIGSERIAL PRIMARY KEY,
    table_name VARCHAR(64) NOT NULL,
    record_id INTEGER NOT NULL,
    action_type audit_action NOT NULL,
    changed_by VARCHAR(255) NOT NULL,
    changed_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    old_values JSONB,
    new_values JSONB
);

-- Lookup table for Owner Types (Eiertype)
CREATE TABLE owner_types (
    id SERIAL PRIMARY KEY,
    type_description VARCHAR(100) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uk_type_description UNIQUE (type_description)
);

-- Table for Organizations (e.g., Prosjekteier and tilknyttede organisasjoner)
CREATE TABLE organizations (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    owner_type_id INTEGER NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_owner_type FOREIGN KEY (owner_type_id) REFERENCES owner_types(id),
    CONSTRAINT uk_organization_name UNIQUE (name)
);

-- Lookup table for Departments
CREATE TABLE departments (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uk_department_name UNIQUE (name)
);

-- Lookup table for Project Status
CREATE TABLE project_status (
    id SERIAL PRIMARY KEY,
    status_name VARCHAR(100) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uk_status_name UNIQUE (status_name)
);

-- Lookup table for Digital Networks (Digitaliseringsnettverk)
CREATE TABLE digital_networks (
    id SERIAL PRIMARY KEY,
    network_name VARCHAR(255) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uk_network_name UNIQUE (network_name)
);

-- Table for Addresses
CREATE TABLE addresses (
    id SERIAL PRIMARY KEY,
    street_address VARCHAR(255) NOT NULL,
    city VARCHAR(255) NOT NULL,
    county VARCHAR(100) NOT NULL,
    country VARCHAR(100) NOT NULL,
    postal_code VARCHAR(20),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Table for Contacts
CREATE TABLE contacts (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    phone VARCHAR(50),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uk_email UNIQUE (email)
);

-- Main Projects table with partitioning
CREATE TABLE projects (
    id SERIAL,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    department_id INTEGER NOT NULL,
    owner_id INTEGER NOT NULL,
    status_id INTEGER NOT NULL,
    modellutvikling VARCHAR(255),
    gevinst_verdi VARCHAR(255),
    digital_network_id INTEGER,
    address_id INTEGER,
    contact_id INTEGER,
    start_date DATE NOT NULL,
    end_date DATE,
    project_link VARCHAR(255),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(255) NOT NULL,
    updated_by VARCHAR(255) NOT NULL,
    CONSTRAINT pk_projects PRIMARY KEY (id, start_date),
    CONSTRAINT fk_department FOREIGN KEY (department_id) REFERENCES departments(id),
    CONSTRAINT fk_owner FOREIGN KEY (owner_id) REFERENCES organizations(id),
    CONSTRAINT fk_status FOREIGN KEY (status_id) REFERENCES project_status(id),
    CONSTRAINT fk_digital_network FOREIGN KEY (digital_network_id) REFERENCES digital_networks(id),
    CONSTRAINT fk_address FOREIGN KEY (address_id) REFERENCES addresses(id),
    CONSTRAINT fk_contact FOREIGN KEY (contact_id) REFERENCES contacts(id)
) PARTITION BY RANGE (start_date);

-- Create partitions
CREATE TABLE projects_2020 PARTITION OF projects
    FOR VALUES FROM ('2020-01-01') TO ('2021-01-01');
CREATE TABLE projects_2021 PARTITION OF projects
    FOR VALUES FROM ('2021-01-01') TO ('2022-01-01');
CREATE TABLE projects_2022 PARTITION OF projects
    FOR VALUES FROM ('2022-01-01') TO ('2023-01-01');
CREATE TABLE projects_2023 PARTITION OF projects
    FOR VALUES FROM ('2023-01-01') TO ('2024-01-01');
CREATE TABLE projects_future PARTITION OF projects
    FOR VALUES FROM ('2024-01-01') TO (MAXVALUE);

-- Join table for associated organizations with audit
CREATE TABLE project_organizations (
    project_id INTEGER NOT NULL,
    organization_id INTEGER NOT NULL,
    project_start_date DATE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(255) NOT NULL,
    updated_by VARCHAR(255) NOT NULL,
    CONSTRAINT pk_project_organizations PRIMARY KEY (project_id, organization_id),
    CONSTRAINT fk_project FOREIGN KEY (project_id, project_start_date) REFERENCES projects(id, start_date),
    CONSTRAINT fk_organization FOREIGN KEY (organization_id) REFERENCES organizations(id)
); 