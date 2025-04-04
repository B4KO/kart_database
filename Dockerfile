# Use the official PostgreSQL image
FROM postgres:latest

# Set environment variables
ENV POSTGRES_DB=kart_database
ENV POSTGRES_USER=kart_admin
ENV POSTGRES_PASSWORD=CHANGE_ADMIN_PASSWORD

# Copy SQL files and initialization script
COPY sql/ /sql/
COPY init-db.sh /docker-entrypoint-initdb.d/

# Make the initialization script executable
RUN chmod +x /docker-entrypoint-initdb.d/init-db.sh

# Create backup directories with proper permissions
RUN mkdir -p /var/backups/kart/{full,incremental,wal} && \
    chown -R postgres:postgres /var/backups/kart && \
    chmod -R 777 /var/backups/kart && \
    chmod g+s /var/backups/kart

# Add healthcheck
HEALTHCHECK --interval=10s --timeout=5s --start-period=5s --retries=5 \
    CMD pg_isready -U kart_admin -d kart_database

# Expose PostgreSQL port
EXPOSE 5432

# Set volume for data persistence
VOLUME ["/var/lib/postgresql/data", "/var/backups/kart"] 