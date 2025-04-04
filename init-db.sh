#!/bin/bash
set -e

# Wait for PostgreSQL to be ready
until pg_isready -U kart_admin -d kart_database; do
  echo "Waiting for PostgreSQL to be ready..."
  sleep 1
done

# Execute SQL files in order
echo "Executing initialization scripts..."
psql -v ON_ERROR_STOP=1 -U kart_admin -d kart_database -f /sql/00_init.sql
psql -v ON_ERROR_STOP=1 -U kart_admin -d kart_database -f /sql/tables/01_tables.sql
psql -v ON_ERROR_STOP=1 -U kart_admin -d kart_database -f /sql/roles/01_roles.sql
psql -v ON_ERROR_STOP=1 -U kart_admin -d kart_database -f /sql/indexes/01_indexes.sql
psql -v ON_ERROR_STOP=1 -U kart_admin -d kart_database -f /sql/functions/01_functions.sql
psql -v ON_ERROR_STOP=1 -U kart_admin -d kart_database -f /sql/triggers/01_triggers.sql
psql -v ON_ERROR_STOP=1 -U kart_admin -d kart_database -f /sql/views/01_views.sql
psql -v ON_ERROR_STOP=1 -U kart_admin -d kart_database -f /sql/backup/01_backup.sql

echo "Database initialization complete!"

# Run tests
echo "Running database tests..."
psql -v ON_ERROR_STOP=1 -U kart_admin -d kart_database -f /sql/test/01_test.sql

echo "All tests completed!" 