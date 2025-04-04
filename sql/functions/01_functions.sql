-- Function to get project duration in years
CREATE OR REPLACE FUNCTION get_project_duration(project_id INTEGER)
RETURNS INTEGER AS $$
DECLARE
    start_year INTEGER;
    end_year INTEGER;
BEGIN
    SELECT p.start_year, p.end_year
    INTO start_year, end_year
    FROM projects p
    WHERE p.id = project_id;

    IF end_year IS NULL THEN
        RETURN EXTRACT(YEAR FROM CURRENT_DATE) - start_year;
    ELSE
        RETURN end_year - start_year;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Function to get all projects for a specific owner
CREATE OR REPLACE FUNCTION get_owner_projects(owner_name VARCHAR)
RETURNS TABLE (
    project_id INTEGER,
    project_title VARCHAR,
    project_status project_status,
    start_year INTEGER,
    end_year INTEGER,
    sector project_sector,
    management_level project_management_level
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        p.id,
        p.title,
        p.status,
        p.start_year,
        p.end_year,
        p.sector,
        p.managment_level
    FROM projects p
    JOIN projects_owners po ON p.id = po.project_id
    JOIN owners o ON po.owner_id = o.id
    WHERE o.name = owner_name;
END;
$$ LANGUAGE plpgsql;

-- Function to get project statistics by sector
CREATE OR REPLACE FUNCTION get_sector_statistics()
RETURNS TABLE (
    sector project_sector,
    total_projects INTEGER,
    active_projects INTEGER,
    completed_projects INTEGER,
    avg_duration_years NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        p.sector,
        COUNT(*) as total_projects,
        COUNT(CASE WHEN p.status = 'IN_PROGRESS' THEN 1 END) as active_projects,
        COUNT(CASE WHEN p.status = 'COMPLETED' THEN 1 END) as completed_projects,
        ROUND(AVG(get_project_duration(p.id)), 1) as avg_duration_years
    FROM projects p
    GROUP BY p.sector;
END;
$$ LANGUAGE plpgsql;

-- Function to search projects by text
CREATE OR REPLACE FUNCTION search_projects(search_text TEXT)
RETURNS TABLE (
    project_id INTEGER,
    project_title VARCHAR,
    project_status project_status,
    sector project_sector,
    start_year INTEGER,
    description TEXT,
    notes TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        p.id,
        p.title,
        p.status,
        p.sector,
        p.start_year,
        p.description,
        p.notes
    FROM projects p
    WHERE 
        to_tsvector('english', COALESCE(p.title, '') || ' ' || 
                             COALESCE(p.description, '') || ' ' || 
                             COALESCE(p.notes, '')) @@ plainto_tsquery('english', search_text);
END;
$$ LANGUAGE plpgsql;

-- Function to get projects by location
CREATE OR REPLACE FUNCTION get_projects_by_location(city_name VARCHAR, county_name VARCHAR)
RETURNS TABLE (
    project_id INTEGER,
    project_title VARCHAR,
    project_status project_status,
    sector project_sector,
    start_year INTEGER,
    end_year INTEGER,
    management_level project_management_level
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        p.id,
        p.title,
        p.status,
        p.sector,
        p.start_year,
        p.end_year,
        p.managment_level
    FROM projects p
    JOIN projects_locations pl ON p.id = pl.project_id
    JOIN addresses a ON pl.location_id = a.id
    WHERE a.city = city_name AND a.county = county_name;
END;
$$ LANGUAGE plpgsql;

-- Function to get project benefits
CREATE OR REPLACE FUNCTION get_project_benefits(project_id INTEGER)
RETURNS TABLE (
    benefit_name VARCHAR,
    benefit_description TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        b.name,
        b.description
    FROM benefits b
    JOIN projects_benefits pb ON b.id = pb.benefit_id
    WHERE pb.project_id = project_id;
END;
$$ LANGUAGE plpgsql;

-- Function to get project contacts
CREATE OR REPLACE FUNCTION get_project_contacts(project_id INTEGER)
RETURNS TABLE (
    contact_name VARCHAR,
    contact_email VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        c.name,
        c.email
    FROM contacts c
    JOIN projects_contacts pc ON c.id = pc.contact_id
    WHERE pc.project_id = project_id;
END;
$$ LANGUAGE plpgsql;

-- Function to get projects by management level
CREATE OR REPLACE FUNCTION get_projects_by_management_level(level project_management_level)
RETURNS TABLE (
    project_id INTEGER,
    project_title VARCHAR,
    project_status project_status,
    sector project_sector,
    start_year INTEGER,
    end_year INTEGER,
    owner_names TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        p.id,
        p.title,
        p.status,
        p.sector,
        p.start_year,
        p.end_year,
        string_agg(o.name, ', ') as owner_names
    FROM projects p
    JOIN projects_owners po ON p.id = po.project_id
    JOIN owners o ON po.owner_id = o.id
    WHERE p.managment_level = level
    GROUP BY p.id, p.title, p.status, p.sector, p.start_year, p.end_year;
END;
$$ LANGUAGE plpgsql;

-- Function to get project timeline statistics
CREATE OR REPLACE FUNCTION get_project_timeline_stats()
RETURNS TABLE (
    year INTEGER,
    total_projects INTEGER,
    active_projects INTEGER,
    completed_projects INTEGER,
    sectors TEXT[]
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        EXTRACT(YEAR FROM CURRENT_DATE) as year,
        COUNT(*) as total_projects,
        COUNT(CASE WHEN status = 'IN_PROGRESS' THEN 1 END) as active_projects,
        COUNT(CASE WHEN status = 'COMPLETED' THEN 1 END) as completed_projects,
        array_agg(DISTINCT sector) as sectors
    FROM projects
    GROUP BY EXTRACT(YEAR FROM CURRENT_DATE);
END;
$$ LANGUAGE plpgsql; 