-- Validation script for test data
DO $$
DECLARE
    address_count INTEGER;
    contact_count INTEGER;
    owner_count INTEGER;
    cooperator_count INTEGER;
    benefit_count INTEGER;
    location_count INTEGER;
    project_count INTEGER;
    project_owner_count INTEGER;
    project_contact_count INTEGER;
    project_location_count INTEGER;
    project_cooperator_count INTEGER;
    project_benefit_count INTEGER;
BEGIN
    -- Check address count
    SELECT COUNT(*) INTO address_count FROM addresses;
    IF address_count != 6 THEN
        RAISE EXCEPTION 'Expected 6 addresses, found %', address_count;
    END IF;

    -- Check contact count
    SELECT COUNT(*) INTO contact_count FROM contacts;
    IF contact_count != 6 THEN
        RAISE EXCEPTION 'Expected 6 contacts, found %', contact_count;
    END IF;

    -- Check owner count
    SELECT COUNT(*) INTO owner_count FROM owners;
    IF owner_count != 4 THEN
        RAISE EXCEPTION 'Expected 4 owners, found %', owner_count;
    END IF;

    -- Check cooperator count
    SELECT COUNT(*) INTO cooperator_count FROM cooperators;
    IF cooperator_count != 6 THEN
        RAISE EXCEPTION 'Expected 6 cooperators, found %', cooperator_count;
    END IF;

    -- Check benefit count
    SELECT COUNT(*) INTO benefit_count FROM benefits;
    IF benefit_count != 6 THEN
        RAISE EXCEPTION 'Expected 6 benefits, found %', benefit_count;
    END IF;

    -- Check location count
    SELECT COUNT(*) INTO location_count FROM locations;
    IF location_count != 6 THEN
        RAISE EXCEPTION 'Expected 6 locations, found %', location_count;
    END IF;

    -- Check project count
    SELECT COUNT(*) INTO project_count FROM projects;
    IF project_count != 6 THEN
        RAISE EXCEPTION 'Expected 6 projects, found %', project_count;
    END IF;

    -- Check project-owner relationships
    SELECT COUNT(*) INTO project_owner_count FROM projects_owners;
    IF project_owner_count != 12 THEN
        RAISE EXCEPTION 'Expected 12 project-owner relationships, found %', project_owner_count;
    END IF;

    -- Check project-contact relationships
    SELECT COUNT(*) INTO project_contact_count FROM projects_contacts;
    IF project_contact_count != 12 THEN
        RAISE EXCEPTION 'Expected 12 project-contact relationships, found %', project_contact_count;
    END IF;

    -- Check project-location relationships
    SELECT COUNT(*) INTO project_location_count FROM projects_locations;
    IF project_location_count != 12 THEN
        RAISE EXCEPTION 'Expected 12 project-location relationships, found %', project_location_count;
    END IF;

    -- Check project-cooperator relationships
    SELECT COUNT(*) INTO project_cooperator_count FROM projects_cooperators;
    IF project_cooperator_count != 12 THEN
        RAISE EXCEPTION 'Expected 12 project-cooperator relationships, found %', project_cooperator_count;
    END IF;

    -- Check project-benefit relationships
    SELECT COUNT(*) INTO project_benefit_count FROM projects_benefits;
    IF project_benefit_count != 12 THEN
        RAISE EXCEPTION 'Expected 12 project-benefit relationships, found %', project_benefit_count;
    END IF;

    -- Check for orphaned records
    IF EXISTS (
        SELECT 1 FROM locations l 
        LEFT JOIN addresses a ON l.address_id = a.id 
        WHERE a.id IS NULL
    ) THEN
        RAISE EXCEPTION 'Found orphaned locations (no matching address)';
    END IF;

    -- Check for orphaned project owners
    IF EXISTS (
        SELECT 1 FROM projects_owners po
        LEFT JOIN projects p ON po.project_id = p.id
        LEFT JOIN owners o ON po.owner_id = o.id
        WHERE p.id IS NULL OR o.id IS NULL
    ) THEN
        RAISE EXCEPTION 'Found orphaned project-owner relationships';
    END IF;

    -- Check for orphaned project cooperators
    IF EXISTS (
        SELECT 1 FROM projects_cooperators pc
        LEFT JOIN projects p ON pc.project_id = p.id
        LEFT JOIN cooperators c ON pc.cooperator_id = c.id
        WHERE p.id IS NULL OR c.id IS NULL
    ) THEN
        RAISE EXCEPTION 'Found orphaned project-cooperator relationships';
    END IF;

    -- Check for orphaned project benefits
    IF EXISTS (
        SELECT 1 FROM projects_benefits pb
        LEFT JOIN projects p ON pb.project_id = p.id
        LEFT JOIN benefits b ON pb.benefit_id = b.id
        WHERE p.id IS NULL OR b.id IS NULL
    ) THEN
        RAISE EXCEPTION 'Found orphaned project-benefit relationships';
    END IF;

    -- Check for orphaned project locations
    IF EXISTS (
        SELECT 1 FROM projects_locations pl
        LEFT JOIN projects p ON pl.project_id = p.id
        LEFT JOIN locations l ON pl.location_id = l.id
        WHERE p.id IS NULL OR l.id IS NULL
    ) THEN
        RAISE EXCEPTION 'Found orphaned project-location relationships';
    END IF;

    -- Check for duplicate project titles
    IF EXISTS (
        SELECT title, COUNT(*)
        FROM projects
        GROUP BY title
        HAVING COUNT(*) > 1
    ) THEN
        RAISE EXCEPTION 'Found duplicate project titles';
    END IF;

    -- Check for duplicate contact emails
    IF EXISTS (
        SELECT email, COUNT(*)
        FROM contacts
        GROUP BY email
        HAVING COUNT(*) > 1
    ) THEN
        RAISE EXCEPTION 'Found duplicate contact emails';
    END IF;

    -- Check for valid project status values
    IF EXISTS (
        SELECT 1 FROM projects 
        WHERE status NOT IN ('DRAFT', 'IN_PROGRESS', 'COMPLETED')
    ) THEN
        RAISE EXCEPTION 'Found invalid project status values';
    END IF;

    -- Check for valid project sector values
    IF EXISTS (
        SELECT 1 FROM projects 
        WHERE sector NOT IN ('EDUCATION', 'ENVIRONMENT', 'HEALTH', 'INNOVATION')
    ) THEN
        RAISE EXCEPTION 'Found invalid project sector values';
    END IF;

    RAISE NOTICE 'All validation checks passed successfully!';
END $$; 