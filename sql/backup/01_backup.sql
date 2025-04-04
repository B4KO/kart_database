-- Create backup configuration table
CREATE TABLE backup_config (
    id SERIAL PRIMARY KEY,
    backup_type VARCHAR(20) NOT NULL CHECK (backup_type IN ('FULL', 'INCREMENTAL')),
    schedule VARCHAR(50) NOT NULL,
    retention_days INTEGER NOT NULL DEFAULT 30,
    backup_path VARCHAR(255) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create backup history table
CREATE TABLE backup_history (
    id SERIAL PRIMARY KEY,
    backup_config_id INTEGER REFERENCES backup_config(id),
    start_time TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    end_time TIMESTAMP WITH TIME ZONE,
    status VARCHAR(20) CHECK (status IN ('SUCCESS', 'FAILED', 'IN_PROGRESS')),
    size_bytes BIGINT,
    error_message TEXT,
    backup_file_path VARCHAR(255)
);

-- Function to perform full backup
CREATE OR REPLACE FUNCTION perform_full_backup(backup_path VARCHAR)
RETURNS INTEGER AS $$
DECLARE
    backup_id INTEGER;
    backup_file_name VARCHAR;
    backup_file_path VARCHAR;
    start_time TIMESTAMP WITH TIME ZONE;
BEGIN
    -- Generate backup file name with timestamp
    backup_file_name := 'kart_database_full_' || TO_CHAR(CURRENT_TIMESTAMP, 'YYYYMMDD_HH24MISS') || '.sql';
    backup_file_path := backup_path || '/' || backup_file_name;
    
    -- Record backup start
    INSERT INTO backup_history (backup_config_id, status, start_time)
    VALUES (1, 'IN_PROGRESS', CURRENT_TIMESTAMP)
    RETURNING id INTO backup_id;

    -- Perform backup using COPY
    EXECUTE format('COPY (SELECT * FROM projects) TO %L', backup_file_path);
    EXECUTE format('COPY (SELECT * FROM owners) TO %L', backup_file_path);
    EXECUTE format('COPY (SELECT * FROM contacts) TO %L', backup_file_path);
    EXECUTE format('COPY (SELECT * FROM benefits) TO %L', backup_file_path);
    EXECUTE format('COPY (SELECT * FROM locations) TO %L', backup_file_path);
    EXECUTE format('COPY (SELECT * FROM projects_owners) TO %L', backup_file_path);
    EXECUTE format('COPY (SELECT * FROM projects_contacts) TO %L', backup_file_path);
    EXECUTE format('COPY (SELECT * FROM projects_locations) TO %L', backup_file_path);
    EXECUTE format('COPY (SELECT * FROM projects_cooperators) TO %L', backup_file_path);
    EXECUTE format('COPY (SELECT * FROM projects_benefits) TO %L', backup_file_path);

    -- Update backup history
    UPDATE backup_history
    SET 
        status = 'SUCCESS',
        end_time = CURRENT_TIMESTAMP,
        backup_file_path = backup_file_path
    WHERE id = backup_id;

    RETURN backup_id;
EXCEPTION WHEN OTHERS THEN
    -- Record failure
    UPDATE backup_history
    SET 
        status = 'FAILED',
        end_time = CURRENT_TIMESTAMP,
        error_message = SQLERRM
    WHERE id = backup_id;
    
    RAISE;
END;
$$ LANGUAGE plpgsql;

-- Function to perform incremental backup
CREATE OR REPLACE FUNCTION perform_incremental_backup(backup_path VARCHAR)
RETURNS INTEGER AS $$
DECLARE
    backup_id INTEGER;
    backup_file_name VARCHAR;
    backup_file_path VARCHAR;
    last_backup_time TIMESTAMP WITH TIME ZONE;
BEGIN
    -- Get last successful backup time
    SELECT MAX(end_time)
    INTO last_backup_time
    FROM backup_history
    WHERE status = 'SUCCESS';

    -- Generate backup file name with timestamp
    backup_file_name := 'kart_database_incr_' || TO_CHAR(CURRENT_TIMESTAMP, 'YYYYMMDD_HH24MISS') || '.sql';
    backup_file_path := backup_path || '/' || backup_file_name;
    
    -- Record backup start
    INSERT INTO backup_history (backup_config_id, status, start_time)
    VALUES (2, 'IN_PROGRESS', CURRENT_TIMESTAMP)
    RETURNING id INTO backup_id;

    -- Perform incremental backup by copying only changed records
    EXECUTE format('COPY (SELECT * FROM projects WHERE updated_at > %L) TO %L', last_backup_time, backup_file_path);
    EXECUTE format('COPY (SELECT * FROM owners WHERE updated_at > %L) TO %L', last_backup_time, backup_file_path);
    EXECUTE format('COPY (SELECT * FROM contacts WHERE updated_at > %L) TO %L', last_backup_time, backup_file_path);
    EXECUTE format('COPY (SELECT * FROM benefits WHERE updated_at > %L) TO %L', last_backup_time, backup_file_path);
    EXECUTE format('COPY (SELECT * FROM locations WHERE updated_at > %L) TO %L', last_backup_time, backup_file_path);

    -- Update backup history
    UPDATE backup_history
    SET 
        status = 'SUCCESS',
        end_time = CURRENT_TIMESTAMP,
        backup_file_path = backup_file_path
    WHERE id = backup_id;

    RETURN backup_id;
EXCEPTION WHEN OTHERS THEN
    -- Record failure
    UPDATE backup_history
    SET 
        status = 'FAILED',
        end_time = CURRENT_TIMESTAMP,
        error_message = SQLERRM
    WHERE id = backup_id;
    
    RAISE;
END;
$$ LANGUAGE plpgsql;

-- Function to clean up old backups
CREATE OR REPLACE FUNCTION cleanup_old_backups(retention_days INTEGER)
RETURNS INTEGER AS $$
DECLARE
    deleted_count INTEGER := 0;
    backup_record RECORD;
BEGIN
    FOR backup_record IN 
        SELECT id, backup_file_path 
        FROM backup_history 
        WHERE end_time < CURRENT_TIMESTAMP - (retention_days || ' days')::INTERVAL
        AND backup_file_path IS NOT NULL
    LOOP
        -- Update backup history
        UPDATE backup_history
        SET backup_file_path = NULL
        WHERE id = backup_record.id;
        
        deleted_count := deleted_count + 1;
    END LOOP;
    
    RETURN deleted_count;
END;
$$ LANGUAGE plpgsql;

-- Function to restore from backup
CREATE OR REPLACE FUNCTION restore_from_backup(backup_file_path VARCHAR)
RETURNS BOOLEAN AS $$
DECLARE
    restore_success BOOLEAN;
BEGIN
    -- Attempt to restore using COPY
    EXECUTE format('COPY projects FROM %L', backup_file_path);
    EXECUTE format('COPY owners FROM %L', backup_file_path);
    EXECUTE format('COPY contacts FROM %L', backup_file_path);
    EXECUTE format('COPY benefits FROM %L', backup_file_path);
    EXECUTE format('COPY locations FROM %L', backup_file_path);
    EXECUTE format('COPY projects_owners FROM %L', backup_file_path);
    EXECUTE format('COPY projects_contacts FROM %L', backup_file_path);
    EXECUTE format('COPY projects_locations FROM %L', backup_file_path);
    EXECUTE format('COPY projects_cooperators FROM %L', backup_file_path);
    EXECUTE format('COPY projects_benefits FROM %L', backup_file_path);
    
    restore_success := TRUE;
    RETURN restore_success;
EXCEPTION WHEN OTHERS THEN
    RETURN FALSE;
END;
$$ LANGUAGE plpgsql;

-- Function to check backup status
CREATE OR REPLACE FUNCTION check_backup_status()
RETURNS TABLE (
    backup_type VARCHAR,
    last_backup TIMESTAMP WITH TIME ZONE,
    status VARCHAR,
    size_bytes BIGINT,
    error_message TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        bc.backup_type,
        MAX(bh.end_time) as last_backup,
        MAX(bh.status) as status,
        MAX(bh.size_bytes) as size_bytes,
        MAX(bh.error_message) as error_message
    FROM backup_config bc
    LEFT JOIN backup_history bh ON bc.id = bh.backup_config_id
    WHERE bc.is_active = TRUE
    GROUP BY bc.id, bc.backup_type;
END;
$$ LANGUAGE plpgsql;

-- Insert default backup configurations
INSERT INTO backup_config (backup_type, schedule, retention_days, backup_path)
VALUES 
    ('FULL', '0 0 * * *', 30, '/var/backups/kart/full'),
    ('INCREMENTAL', '0 */4 * * *', 7, '/var/backups/kart/incremental'); 