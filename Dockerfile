# Use the official PostgreSQL image
FROM postgres:latest

# Set environment variables
ENV POSTGRES_DB=kart_database
ENV POSTGRES_USER=kart_admin
ENV POSTGRES_PASSWORD=CHANGE_ADMIN_PASSWORD

# Copy SQL files
COPY sql/ /docker-entrypoint-initdb.d/

# Create backup directory
RUN mkdir -p /var/backups/kart/{full,incremental,wal} && \
    chown -R postgres:postgres /var/backups/kart

# Add healthcheck
HEALTHCHECK --interval=10s --timeout=5s --start-period=5s --retries=5 \
    CMD pg_isready -U kart_admin -d kart_database

# Expose PostgreSQL port
EXPOSE 5432

# Set volume for data persistence
VOLUME ["/var/lib/postgresql/data", "/var/backups/kart"] 