-- Insert test users
INSERT INTO users (email, username, hashed_password, role) VALUES
('admin@kart.com', 'admin', '$2b$12$EixZaYVK1fsbw1ZfbX3OXePaWxn96p36WQoeG6Lruj3vjPGga31lW', 'ADMIN'),
('user@kart.com', 'user', '$2b$12$EixZaYVK1fsbw1ZfbX3OXePaWxn96p36WQoeG6Lruj3vjPGga31lW', 'USER');

-- Insert test addresses
INSERT INTO addresses (city, county, postal_code) VALUES
('Bucharest', 'Bucharest', '010101'),
('Cluj-Napoca', 'Cluj', '400001'),
('Timisoara', 'Timis', '300001'),
('Iasi', 'Iasi', '700001'),
('Brasov', 'Brasov', '500001'),
('Constanta', 'Constanta', '900001');

-- Insert test contacts
INSERT INTO contacts (name, email) VALUES
('John Doe', 'john.doe@example.com'),
('Jane Smith', 'jane.smith@example.com'),
('Bob Johnson', 'bob.johnson@example.com'),
('Alice Brown', 'alice.brown@example.com'),
('Charlie Wilson', 'charlie.wilson@example.com'),
('Diana Miller', 'diana.miller@example.com'),
('Ethan Davis', 'ethan.davis@example.com'),
('Fiona Clark', 'fiona.clark@example.com');

-- Insert test owners
INSERT INTO owners (name, description) VALUES
('Ministry of Education', 'National education authority'),
('Local Council Cluj', 'Local government of Cluj county'),
('Tech Company SRL', 'Private technology company'),
('Environmental NGO', 'Non-governmental organization focused on environmental protection'),
('Ministry of Health', 'National health authority'),
('Ministry of Environment', 'National environmental authority'),
('Local Council Bucharest', 'Local government of Bucharest'),
('Innovation Agency', 'Government agency for innovation');

-- Insert test cooperators
INSERT INTO cooperators (name) VALUES
('University of Bucharest'),
('Technical University of Cluj'),
('Research Institute'),
('Innovation Hub'),
('University of Medicine'),
('Environmental Research Center'),
('Technology Transfer Office'),
('Business Incubator');

-- Insert test benefits
INSERT INTO benefits (name, description) VALUES
('Digital Skills', 'Improving digital literacy in the community'),
('Economic Growth', 'Creating new job opportunities'),
('Environmental Impact', 'Reducing carbon footprint'),
('Social Inclusion', 'Promoting equal opportunities'),
('Health Improvement', 'Enhancing public health services'),
('Education Quality', 'Improving educational outcomes'),
('Urban Development', 'Modernizing city infrastructure'),
('Research Advancement', 'Promoting scientific research');

-- Insert test locations
INSERT INTO locations (address_id, name, description) VALUES
(1, 'Main Office', 'Primary office location in Bucharest'),
(2, 'Regional Center', 'Regional office in Cluj'),
(3, 'Research Facility', 'Research and development center'),
(4, 'Training Center', 'Educational and training facility'),
(5, 'Health Center', 'Medical research and training facility'),
(6, 'Environmental Lab', 'Environmental research laboratory');

-- Insert test projects
INSERT INTO projects (title, description, status, start_year, end_year, sector, project_link, notes, managment_level) VALUES
('Digital Education Initiative', 'Modernizing education through technology', 'IN_PROGRESS', 2023, 2025, 'EDUCATION', 'https://example.com/digital-edu', 'Focus on primary schools', 'NATIONAL'),
('Green City Project', 'Sustainable urban development', 'DRAFT', 2024, 2026, 'ENVIRONMENT', 'https://example.com/green-city', 'Pilot program in Cluj', 'REGIONAL'),
('Healthcare Innovation', 'Digital healthcare solutions', 'COMPLETED', 2022, 2023, 'HEALTH', 'https://example.com/healthcare', 'Successfully implemented', 'LOCAL'),
('Smart Infrastructure', 'Modern infrastructure development', 'IN_PROGRESS', 2023, 2024, 'INNOVATION', 'https://example.com/smart-infra', 'Focus on transportation', 'REGIONAL'),
('Environmental Research Program', 'Climate change research initiative', 'IN_PROGRESS', 2023, 2025, 'ENVIRONMENT', 'https://example.com/environment', 'Multi-regional research', 'NATIONAL'),
('Digital Health Platform', 'National healthcare digitalization', 'DRAFT', 2024, 2026, 'HEALTH', 'https://example.com/digital-health', 'Integration with existing systems', 'NATIONAL');

-- Link projects with owners (multiple owners per project)
INSERT INTO projects_owners (project_id, owner_id) VALUES
-- Digital Education Initiative
(1, 1), -- Ministry of Education
(1, 7), -- Local Council Bucharest
-- Green City Project
(2, 2), -- Local Council Cluj
(2, 6), -- Ministry of Environment
-- Healthcare Innovation
(3, 5), -- Ministry of Health
(3, 3), -- Tech Company SRL
-- Smart Infrastructure
(4, 7), -- Local Council Bucharest
(4, 8), -- Innovation Agency
-- Environmental Research Program
(5, 6), -- Ministry of Environment
(5, 4), -- Environmental NGO
-- Digital Health Platform
(6, 5), -- Ministry of Health
(6, 3); -- Tech Company SRL

-- Link projects with contacts (multiple contacts per project)
INSERT INTO projects_contacts (project_id, contact_id) VALUES
-- Digital Education Initiative
(1, 1), -- John Doe
(1, 5), -- Charlie Wilson
-- Green City Project
(2, 2), -- Jane Smith
(2, 6), -- Diana Miller
-- Healthcare Innovation
(3, 3), -- Bob Johnson
(3, 7), -- Ethan Davis
-- Smart Infrastructure
(4, 4), -- Alice Brown
(4, 8), -- Fiona Clark
-- Environmental Research Program
(5, 1), -- John Doe
(5, 2), -- Jane Smith
-- Digital Health Platform
(6, 3), -- Bob Johnson
(6, 4); -- Alice Brown

-- Link projects with locations (multiple locations per project)
INSERT INTO projects_locations (project_id, location_id) VALUES
-- Digital Education Initiative
(1, 1), -- Main Office
(1, 4), -- Training Center
-- Green City Project
(2, 2), -- Regional Center
(2, 6), -- Environmental Lab
-- Healthcare Innovation
(3, 3), -- Research Facility
(3, 5), -- Health Center
-- Smart Infrastructure
(4, 1), -- Main Office
(4, 2), -- Regional Center
-- Environmental Research Program
(5, 3), -- Research Facility
(5, 6), -- Environmental Lab
-- Digital Health Platform
(6, 1), -- Main Office
(6, 5); -- Health Center

-- Link projects with cooperators (multiple cooperators per project)
INSERT INTO projects_cooperators (project_id, cooperator_id) VALUES
-- Digital Education Initiative
(1, 1), -- University of Bucharest
(1, 7), -- Technology Transfer Office
-- Green City Project
(2, 2), -- Technical University of Cluj
(2, 6), -- Environmental Research Center
-- Healthcare Innovation
(3, 5), -- University of Medicine
(3, 3), -- Research Institute
-- Smart Infrastructure
(4, 4), -- Innovation Hub
(4, 8), -- Business Incubator
-- Environmental Research Program
(5, 3), -- Research Institute
(5, 6), -- Environmental Research Center
-- Digital Health Platform
(6, 5), -- University of Medicine
(6, 7); -- Technology Transfer Office

-- Link projects with benefits (multiple benefits per project)
INSERT INTO projects_benefits (project_id, benefit_id) VALUES
-- Digital Education Initiative
(1, 1), -- Digital Skills
(1, 6), -- Education Quality
-- Green City Project
(2, 3), -- Environmental Impact
(2, 7), -- Urban Development
-- Healthcare Innovation
(3, 5), -- Health Improvement
(3, 2), -- Economic Growth
-- Smart Infrastructure
(4, 7), -- Urban Development
(4, 2), -- Economic Growth
-- Environmental Research Program
(5, 3), -- Environmental Impact
(5, 8), -- Research Advancement
-- Digital Health Platform
(6, 5), -- Health Improvement
(6, 1); -- Digital Skills 