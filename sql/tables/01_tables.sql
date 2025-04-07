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

CREATE TABLE users (
    id SERIAL PRIMARY KEY,¨
    email VARCHAR(255) NOT NULL UNIQUE,
    username VARCHAR(255) NOT NULL UNIQUE,
    hashed_password VARCHAR(255) NOT NULL,
    role roles NOT NULL
)

-- Table for Addresses
CREATE TABLE addresses (
    id SERIAL PRIMARY KEY,
    city VARCHAR(255) NOT NULL,
    county VARCHAR(100) NOT NULL,
    postal_code VARCHAR(20)
);

-- Table for Contacts
CREATE TABLE contacts (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE owners (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE cooperators (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL
);

CREATE TABLE benefits (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE locations (
    id SERIAL PRIMARY KEY,
    address_id INTEGER NOT NULL REFERENCES addresses(id),
    name VARCHAR(255) NOT NULL,
    description TEXT
);

-- Main Projects table
CREATE TABLE projects (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL UNIQUE,
    description TEXT,
    status project_status NOT NULL DEFAULT 'DRAFT',
    start_year INTEGER NOT NULL,
    end_year INTEGER,
    sector project_sector NOT NULL,
    project_link VARCHAR(255),
    notes TEXT,
    managment_level project_management_level NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE projects_owners (
    project_id INTEGER NOT NULL,
    owner_id INTEGER NOT NULL,
    PRIMARY KEY (project_id, owner_id),
    FOREIGN KEY (project_id) REFERENCES projects(id),
    FOREIGN KEY (owner_id) REFERENCES owners(id)
);

CREATE TABLE projects_contacts (
    project_id INTEGER NOT NULL,
    contact_id INTEGER NOT NULL,
    PRIMARY KEY (project_id, contact_id),
    FOREIGN KEY (project_id) REFERENCES projects(id),
    FOREIGN KEY (contact_id) REFERENCES contacts(id)
);

CREATE TABLE projects_locations (
    project_id INTEGER NOT NULL,
    location_id INTEGER NOT NULL,
    PRIMARY KEY (project_id, location_id),
    FOREIGN KEY (project_id) REFERENCES projects(id),
    FOREIGN KEY (location_id) REFERENCES locations(id)
);

CREATE TABLE projects_cooperators (
    project_id INTEGER NOT NULL,
    cooperator_id INTEGER NOT NULL,
    PRIMARY KEY (project_id, cooperator_id),
    FOREIGN KEY (project_id) REFERENCES projects(id),
    FOREIGN KEY (cooperator_id) REFERENCES cooperators(id)
);

CREATE TABLE projects_benefits (
    project_id INTEGER NOT NULL,
    benefit_id INTEGER NOT NULL,
    PRIMARY KEY (project_id, benefit_id),
    FOREIGN KEY (project_id) REFERENCES projects(id),
    FOREIGN KEY (benefit_id) REFERENCES benefits(id)
);