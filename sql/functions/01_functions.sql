-- Function for updating timestamps
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Function to perform backup
CREATE OR REPLACE FUNCTION perform_backup(
    p_backup_type VARCHAR(50),
    p_backup_path VARCHAR(255)
) RETURNS INTEGER AS $$
DECLARE
    v_backup_id INTEGER;
    v_config_id INTEGER;
BEGIN
    -- Get backup configuration
    SELECT id INTO v_config_id
    FROM backup_config
    WHERE backup_type = p_backup_type AND is_active = TRUE;

    IF v_config_id IS NULL THEN
        RAISE EXCEPTION 'No active backup configuration found for type %', p_backup_type;
    END IF;

    -- Insert backup history record
    INSERT INTO backup_history (
        backup_config_id, start_time, status
    ) VALUES (
        v_config_id, CURRENT_TIMESTAMP, 'STARTED'
    ) RETURNING id INTO v_backup_id;

    -- Perform backup based on type
    CASE p_backup_type
        WHEN 'FULL' THEN
            -- Perform full backup using pg_dump
            PERFORM pg_execute('pg_dump -Fc -f ' || p_backup_path || '/' || 
                             to_char(CURRENT_TIMESTAMP, 'YYYYMMDD_HH24MISS') || '.dump kart_database');
        WHEN 'INCREMENTAL' THEN
            -- Perform incremental backup using pg_basebackup
            PERFORM pg_execute('pg_basebackup -D ' || p_backup_path || '/' || 
                             to_char(CURRENT_TIMESTAMP, 'YYYYMMDD_HH24MISS'));
        WHEN 'WAL' THEN
            -- Archive WAL files
            PERFORM pg_switch_wal();
    END CASE;

    -- Update backup history record
    UPDATE backup_history
    SET status = 'COMPLETED',
        end_time = CURRENT_TIMESTAMP
    WHERE id = v_backup_id;

    RETURN v_backup_id;
EXCEPTION WHEN OTHERS THEN
    -- Update backup history record with error
    UPDATE backup_history
    SET status = 'FAILED',
        end_time = CURRENT_TIMESTAMP,
        error_message = SQLERRM
    WHERE id = v_backup_id;
    
    RAISE;
END;
$$ LANGUAGE plpgsql;

-- Function to clean up old backups
CREATE OR REPLACE FUNCTION cleanup_old_backups() RETURNS void AS $$
DECLARE
    v_config RECORD;
BEGIN
    FOR v_config IN 
        SELECT * FROM backup_config WHERE is_active = TRUE
    LOOP
        -- Delete old backup files based on retention period
        PERFORM pg_execute('find ' || v_config.backup_path || 
                         ' -type f -mtime +' || v_config.retention_days || 
                         ' -delete');
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- Function to check backup status
CREATE OR REPLACE FUNCTION check_backup_status() RETURNS TABLE (
    backup_type VARCHAR(50),
    last_backup TIMESTAMP WITH TIME ZONE,
    status VARCHAR(50),
    size_bytes BIGINT,
    error_message TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        bc.backup_type,
        MAX(bh.start_time) as last_backup,
        MAX(bh.status) as status,
        MAX(bh.size_bytes) as size_bytes,
        MAX(bh.error_message) as error_message
    FROM backup_config bc
    LEFT JOIN backup_history bh ON bc.id = bh.backup_config_id
    WHERE bc.is_active = TRUE
    GROUP BY bc.backup_type;
END;
$$ LANGUAGE plpgsql;

-- Function to monitor backup health
CREATE OR REPLACE FUNCTION monitor_backup_health() RETURNS TABLE (
    backup_type VARCHAR(50),
    status VARCHAR(50),
    last_backup TIMESTAMP WITH TIME ZONE,
    hours_since_last_backup NUMERIC,
    is_healthy BOOLEAN
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        bc.backup_type,
        MAX(bh.status) as status,
        MAX(bh.start_time) as last_backup,
        EXTRACT(EPOCH FROM (CURRENT_TIMESTAMP - MAX(bh.start_time))) / 3600 as hours_since_last_backup,
        CASE 
            WHEN MAX(bh.start_time) IS NULL THEN FALSE
            WHEN EXTRACT(EPOCH FROM (CURRENT_TIMESTAMP - MAX(bh.start_time))) / 3600 > 24 THEN FALSE
            WHEN MAX(bh.status) = 'FAILED' THEN FALSE
            ELSE TRUE
        END as is_healthy
    FROM backup_config bc
    LEFT JOIN backup_history bh ON bc.id = bh.backup_config_id
    WHERE bc.is_active = TRUE
    GROUP BY bc.backup_type;
END;
$$ LANGUAGE plpgsql;

-- Function for alerting backup failures
CREATE OR REPLACE FUNCTION alert_backup_failure() RETURNS TRIGGER AS $$
BEGIN
    IF NEW.status = 'FAILED' THEN
        -- Here you would implement your alert mechanism (email, SMS, etc.)
        -- For example, you could insert into an alerts table or call an external service
        RAISE NOTICE 'Backup failed for type %: %', NEW.backup_type, NEW.error_message;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql; 