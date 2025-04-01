-- Create view for active projects
CREATE VIEW v_active_projects AS
SELECT 
    p.id,
    p.title,
    p.description,
    d.name as department_name,
    o.name as owner_name,
    ps.status_name,
    dn.network_name,
    a.street_address,
    a.city,
    a.county,
    c.name as contact_name,
    c.email as contact_email
FROM projects p
JOIN departments d ON p.department_id = d.id
JOIN organizations o ON p.owner_id = o.id
JOIN project_status ps ON p.status_id = ps.id
LEFT JOIN digital_networks dn ON p.digital_network_id = dn.id
LEFT JOIN addresses a ON p.address_id = a.id
LEFT JOIN contacts c ON p.contact_id = c.id
WHERE p.is_active = TRUE;

-- Create monitoring view for backup status
CREATE VIEW v_backup_status AS
SELECT 
    bc.backup_type,
    bc.schedule,
    bc.retention_days,
    bc.is_active,
    MAX(bh.start_time) as last_backup,
    MAX(bh.status) as last_status,
    MAX(bh.size_bytes) as last_size,
    MAX(bh.error_message) as last_error
FROM backup_config bc
LEFT JOIN backup_history bh ON bc.id = bh.backup_config_id
GROUP BY bc.id, bc.backup_type, bc.schedule, bc.retention_days, bc.is_active;

-- Grant appropriate permissions to roles
GRANT SELECT ON v_active_projects TO kart_admin, kart_app_user, kart_readonly;
GRANT SELECT ON v_backup_status TO kart_admin, kart_app_user, kart_readonly; 