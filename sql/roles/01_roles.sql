-- Database Administrator Role (Full access)
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'kart_admin') THEN
        CREATE ROLE kart_admin WITH LOGIN PASSWORD 'CHANGE_ADMIN_PASSWORD';
    END IF;
END $$;

GRANT ALL PRIVILEGES ON DATABASE kart_database TO kart_admin;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO kart_admin;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO kart_admin;
GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA public TO kart_admin;

-- Application User Role (Limited access for normal operations)
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'kart_app_user') THEN
        CREATE ROLE kart_app_user WITH LOGIN PASSWORD 'CHANGE_APP_PASSWORD';
    END IF;
END $$;

GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA public TO kart_app_user;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO kart_app_user;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO kart_app_user;

-- Read-only User Role (For reporting and analysis)
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'kart_readonly') THEN
        CREATE ROLE kart_readonly;
    END IF;
END $$;

GRANT CONNECT ON DATABASE kart_database TO kart_readonly;
GRANT USAGE ON SCHEMA public TO kart_readonly;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO kart_readonly;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO kart_readonly;

-- Backup User Role (For backup operations)
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'kart_backup') THEN
        CREATE ROLE kart_backup WITH LOGIN PASSWORD 'CHANGE_BACKUP_PASSWORD';
    END IF;
END $$;

GRANT SELECT ON ALL TABLES IN SCHEMA public TO kart_backup;
GRANT SELECT ON ALL SEQUENCES IN SCHEMA public TO kart_backup;

-- Create read-write role
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'kart_readwrite') THEN
        CREATE ROLE kart_readwrite;
    END IF;
END $$;

GRANT CONNECT ON DATABASE kart_database TO kart_readwrite;
GRANT USAGE ON SCHEMA public TO kart_readwrite;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO kart_readwrite;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO kart_readwrite;

-- Grant sequence usage to read-write role
GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO kart_readwrite;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT USAGE ON SEQUENCES TO kart_readwrite;

-- Create application roles
ALTER USER kart_admin WITH SUPERUSER; 