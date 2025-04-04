-- View for projects with all related information
CREATE VIEW project_details AS
SELECT 
    p.id,
    p.title,
    p.description,
    p.status,
    p.start_year,
    p.end_year,
    p.sector,
    p.project_link,
    p.notes,
    p.managment_level,
    string_agg(DISTINCT o.name, ', ') as owners,
    string_agg(DISTINCT c.name, ', ') as contacts,
    string_agg(DISTINCT a.city || ', ' || a.county, '; ') as locations,
    string_agg(DISTINCT co.name, ', ') as cooperators,
    string_agg(DISTINCT b.name, ', ') as benefits
FROM projects p
LEFT JOIN projects_owners po ON p.id = po.project_id
LEFT JOIN owners o ON po.owner_id = o.id
LEFT JOIN projects_contacts pc ON p.id = pc.project_id
LEFT JOIN contacts c ON pc.contact_id = c.id
LEFT JOIN projects_locations pl ON p.id = pl.project_id
LEFT JOIN locations l ON pl.location_id = l.id
LEFT JOIN addresses a ON l.address_id = a.id
LEFT JOIN projects_cooperators pco ON p.id = pco.project_id
LEFT JOIN cooperators co ON pco.cooperator_id = co.id
LEFT JOIN projects_benefits pb ON p.id = pb.project_id
LEFT JOIN benefits b ON pb.benefit_id = b.id
GROUP BY 
    p.id,
    p.title,
    p.description,
    p.status,
    p.start_year,
    p.end_year,
    p.sector,
    p.project_link,
    p.notes,
    p.managment_level;

-- View for project statistics by sector and status
CREATE VIEW project_statistics AS
SELECT 
    sector,
    status,
    COUNT(*) as total_projects,
    COUNT(CASE WHEN end_year IS NULL THEN 1 END) as active_projects,
    COUNT(CASE WHEN end_year IS NOT NULL THEN 1 END) as completed_projects,
    MIN(start_year) as earliest_start,
    MAX(start_year) as latest_start
FROM projects
GROUP BY sector, status;

-- View for projects by management level
CREATE VIEW management_level_projects AS
SELECT 
    managment_level,
    COUNT(*) as project_count,
    COUNT(DISTINCT sector) as sectors_covered,
    string_agg(DISTINCT sector::text, ', ') as sectors
FROM projects
GROUP BY managment_level;

-- View for projects by location
CREATE VIEW location_projects AS
SELECT 
    a.city,
    a.county,
    COUNT(DISTINCT p.id) as project_count,
    string_agg(DISTINCT p.sector::text, ', ') as sectors,
    string_agg(DISTINCT p.status::text, ', ') as statuses
FROM locations l
JOIN addresses a ON l.address_id = a.id
JOIN projects_locations pl ON l.id = pl.location_id
JOIN projects p ON pl.project_id = p.id
GROUP BY a.city, a.county;

-- View for projects by owner
CREATE VIEW owner_projects AS
SELECT 
    o.name as owner_name,
    COUNT(DISTINCT p.id) as project_count,
    COUNT(DISTINCT p.sector) as sectors_involved,
    string_agg(DISTINCT p.sector::text, ', ') as sectors,
    string_agg(DISTINCT p.status::text, ', ') as statuses
FROM owners o
JOIN projects_owners po ON o.id = po.owner_id
JOIN projects p ON po.project_id = p.id
GROUP BY o.id, o.name;

-- Grant appropriate permissions to roles
GRANT SELECT ON project_details TO kart_admin, kart_app_user, kart_readonly;
GRANT SELECT ON project_statistics TO kart_admin, kart_app_user, kart_readonly;
GRANT SELECT ON management_level_projects TO kart_admin, kart_app_user, kart_readonly;
GRANT SELECT ON location_projects TO kart_admin, kart_app_user, kart_readonly;
GRANT SELECT ON owner_projects TO kart_admin, kart_app_user, kart_readonly; 