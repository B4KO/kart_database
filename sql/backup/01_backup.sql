-- Create backup configuration table
CREATE TABLE backup_config (
    id SERIAL PRIMARY KEY,
    backup_type VARCHAR(50) NOT NULL,
    schedule VARCHAR(100) NOT NULL,
    retention_days INTEGER NOT NULL,
    backup_path VARCHAR(255) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(255) NOT NULL,
    updated_by VARCHAR(255) NOT NULL,
    CONSTRAINT uk_backup_type UNIQUE (backup_type)
);

-- Create backup history table
CREATE TABLE backup_history (
    id SERIAL PRIMARY KEY,
    backup_config_id INTEGER NOT NULL,
    start_time TIMESTAMP WITH TIME ZONE NOT NULL,
    end_time TIMESTAMP WITH TIME ZONE,
    status VARCHAR(50) NOT NULL,
    size_bytes BIGINT,
    error_message TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_backup_config FOREIGN KEY (backup_config_id) REFERENCES backup_config(id)
);

-- Insert default backup configurations
INSERT INTO backup_config (
    backup_type, schedule, retention_days, backup_path, created_by, updated_by
) VALUES 
    ('FULL', '0 0 * * *', 30, '/var/backups/kart/full', 'kart_admin', 'kart_admin'),
    ('INCREMENTAL', '0 */4 * * *', 7, '/var/backups/kart/incremental', 'kart_admin', 'kart_admin'),
    ('WAL', '*/15 * * * *', 3, '/var/backups/kart/wal', 'kart_admin', 'kart_admin');

-- Create scheduled backup job using pg_cron extension
CREATE EXTENSION IF NOT EXISTS pg_cron;

-- Schedule backup jobs
SELECT cron.schedule('0 0 * * *', $$SELECT perform_backup('FULL', '/var/backups/kart/full')$$);
SELECT cron.schedule('0 */4 * * *', $$SELECT perform_backup('INCREMENTAL', '/var/backups/kart/incremental')$$);
SELECT cron.schedule('*/15 * * * *', $$SELECT perform_backup('WAL', '/var/backups/kart/wal')$$);

-- Schedule cleanup job (run daily at 1 AM)
SELECT cron.schedule('0 1 * * *', $$SELECT cleanup_old_backups()$$); 