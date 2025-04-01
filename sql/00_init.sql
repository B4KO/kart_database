-- Enable strict mode for better data integrity
SET session_replication_role = 'replica';

-- Create custom types
CREATE TYPE audit_action AS ENUM ('INSERT', 'UPDATE', 'DELETE');

-- Include all other SQL files
\i /docker-entrypoint-initdb.d/tables/01_tables.sql
\i /docker-entrypoint-initdb.d/roles/01_roles.sql
\i /docker-entrypoint-initdb.d/indexes/01_indexes.sql
\i /docker-entrypoint-initdb.d/functions/01_functions.sql
\i /docker-entrypoint-initdb.d/triggers/01_triggers.sql
\i /docker-entrypoint-initdb.d/views/01_views.sql
\i /docker-entrypoint-initdb.d/backup/01_backup.sql 