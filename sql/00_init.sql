-- Enable strict mode for better data integrity
SET session_replication_role = 'replica';

-- Create custom types
CREATE TYPE audit_action AS ENUM ('INSERT', 'UPDATE', 'DELETE');
CREATE TYPE project_status AS ENUM ('DRAFT', 'IN_PROGRESS', 'COMPLETED', 'ON_HOLD', 'CANCELLED', 'POSTPONED');
CREATE TYPE project_sector AS ENUM ('IT', 'ECONOMY', 'ENVIRONMENT', 'SOCIETY', 'GOVERNMENT', 'HEALTH', 'EDUCATION', 'INNOVATION', 'OTHER');
CREATE TYPE project_management_level AS ENUM ('NATIONAL', 'REGIONAL', 'LOCAL');
CREATE TYPE role AS ENUM ('USER', 'ADMIN');