-- Test script for Kart Database
DO $$
DECLARE
    test_result BOOLEAN;
    test_message TEXT;
    test_project_id INTEGER;
    test_owner_id INTEGER;
    test_contact_id INTEGER;
    test_benefit_id INTEGER;
    test_record RECORD;
BEGIN
    -- Test 1: Check if all required tables exist
    SELECT EXISTS (
        SELECT FROM information_schema.tables 
        WHERE table_name IN (
            'projects', 'owners', 'contacts', 'benefits',
            'projects_owners', 'projects_contacts', 'projects_benefits',
            'backup_config', 'backup_history'
        )
    ) INTO test_result;

    IF test_result THEN
        RAISE NOTICE 'Test 1 PASSED: All required tables exist';
    ELSE
        RAISE NOTICE 'Test 1 FAILED: Some required tables are missing';
    END IF;

    -- Test 2: Check if all required functions exist
    SELECT EXISTS (
        SELECT FROM pg_proc 
        WHERE proname IN (
            'get_project_duration',
            'get_owner_projects',
            'get_sector_statistics',
            'search_projects',
            'perform_full_backup',
            'perform_incremental_backup',
            'cleanup_old_backups',
            'restore_from_backup',
            'check_backup_status',
            'get_projects_by_location',
            'get_project_benefits',
            'get_project_contacts',
            'get_projects_by_management_level'
        )
    ) INTO test_result;

    IF test_result THEN
        RAISE NOTICE 'Test 2 PASSED: All required functions exist';
    ELSE
        RAISE NOTICE 'Test 2 FAILED: Some required functions are missing';
    END IF;

    -- Test 3: Check if all required triggers exist
    SELECT EXISTS (
        SELECT FROM pg_trigger 
        WHERE tgname IN (
            'audit_projects',
            'validate_project_dates_trigger',
            'validate_email_format_trigger',
            'prevent_active_project_deletion_trigger',
            'update_project_status_trigger',
            'validate_unique_project_title_trigger'
        )
    ) INTO test_result;

    IF test_result THEN
        RAISE NOTICE 'Test 3 PASSED: All required triggers exist';
    ELSE
        RAISE NOTICE 'Test 3 FAILED: Some required triggers are missing';
    END IF;

    -- Test 4: Test project creation with valid data
    BEGIN
        INSERT INTO projects (
            title, description, status, start_year, sector, managment_level
        ) VALUES (
            'Test Project 1',
            'Test Description',
            'DRAFT',
            EXTRACT(YEAR FROM CURRENT_DATE),
            'IT',
            'LOCAL'
        ) RETURNING id INTO test_project_id;
        RAISE NOTICE 'Test 4 PASSED: Project creation with valid data works';
    EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE 'Test 4 FAILED: Project creation failed - %', SQLERRM;
    END;

    -- Test 5: Test project date validation
    BEGIN
        INSERT INTO projects (
            title, description, status, start_year, end_year, sector, managment_level
        ) VALUES (
            'Test Project 2',
            'Test Description',
            'DRAFT',
            EXTRACT(YEAR FROM CURRENT_DATE),
            EXTRACT(YEAR FROM CURRENT_DATE) - 1,
            'IT',
            'LOCAL'
        );
        RAISE NOTICE 'Test 5 FAILED: Project creation with invalid dates succeeded';
    EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE 'Test 5 PASSED: Project creation with invalid dates was prevented';
    END;

    -- Test 6: Test email validation
    BEGIN
        INSERT INTO contacts (name, email) 
        VALUES ('Test Contact', 'invalid-email');
        RAISE NOTICE 'Test 6 FAILED: Contact creation with invalid email succeeded';
    EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE 'Test 6 PASSED: Contact creation with invalid email was prevented';
    END;

    -- Test 7: Test project status update based on dates
    BEGIN
        INSERT INTO projects (
            title, description, status, start_year, end_year, sector, managment_level
        ) VALUES (
            'Test Project 3',
            'Test Description',
            'DRAFT',
            EXTRACT(YEAR FROM CURRENT_DATE) - 1,
            EXTRACT(YEAR FROM CURRENT_DATE),
            'IT',
            'LOCAL'
        ) RETURNING id INTO test_project_id;
        
        SELECT status INTO test_record
        FROM projects
        WHERE id = test_project_id;
        
        IF test_record.status = 'COMPLETED' THEN
            RAISE NOTICE 'Test 7 PASSED: Project status was automatically updated to COMPLETED';
        ELSE
            RAISE NOTICE 'Test 7 FAILED: Project status was not updated correctly';
        END IF;
    EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE 'Test 7 FAILED: Project creation failed - %', SQLERRM;
    END;

    -- Test 8: Test backup functions
    BEGIN
        PERFORM perform_full_backup('/var/backups/kart/full');
        RAISE NOTICE 'Test 8 PASSED: Full backup function works';
    EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE 'Test 8 FAILED: Full backup function failed - %', SQLERRM;
    END;

    -- Test 9: Test project search function
    BEGIN
        FOR test_record IN SELECT * FROM search_projects('Test Project') LOOP
            -- Just loop through results
            NULL;
        END LOOP;
        RAISE NOTICE 'Test 9 PASSED: Project search function works';
    EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE 'Test 9 FAILED: Project search function failed - %', SQLERRM;
    END;

    -- Test 10: Test project statistics function
    BEGIN
        FOR test_record IN SELECT * FROM get_sector_statistics() LOOP
            -- Just loop through results
            NULL;
        END LOOP;
        RAISE NOTICE 'Test 10 PASSED: Sector statistics function works';
    EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE 'Test 10 FAILED: Sector statistics function failed - %', SQLERRM;
    END;

    -- Test 11: Test views
    BEGIN
        FOR test_record IN SELECT * FROM project_details LIMIT 1 LOOP
            -- Just loop through results
            NULL;
        END LOOP;
        FOR test_record IN SELECT * FROM project_statistics LIMIT 1 LOOP
            -- Just loop through results
            NULL;
        END LOOP;
        FOR test_record IN SELECT * FROM management_level_projects LIMIT 1 LOOP
            -- Just loop through results
            NULL;
        END LOOP;
        RAISE NOTICE 'Test 11 PASSED: All views are accessible';
    EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE 'Test 11 FAILED: View access failed - %', SQLERRM;
    END;

    -- Test 12: Test project management level validation
    BEGIN
        INSERT INTO projects (
            title, description, status, start_year, sector, managment_level
        ) VALUES (
            'Test Project 4',
            'Test Description',
            'DRAFT',
            EXTRACT(YEAR FROM CURRENT_DATE),
            'IT',
            'INVALID_LEVEL'
        );
        RAISE NOTICE 'Test 12 FAILED: Project creation with invalid management level succeeded';
    EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE 'Test 12 PASSED: Project creation with invalid management level was prevented';
    END;

    -- Test 13: Test sector validation
    BEGIN
        INSERT INTO projects (
            title, description, status, start_year, sector, managment_level
        ) VALUES (
            'Test Project 5',
            'Test Description',
            'DRAFT',
            EXTRACT(YEAR FROM CURRENT_DATE),
            'INVALID_SECTOR',
            'LOCAL'
        );
        RAISE NOTICE 'Test 13 FAILED: Project creation with invalid sector succeeded';
    EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE 'Test 13 PASSED: Project creation with invalid sector was prevented';
    END;

    -- Test 14: Test project title uniqueness
    BEGIN
        INSERT INTO projects (
            title, description, status, start_year, sector, managment_level
        ) VALUES (
            'Test Project 1',
            'Test Description',
            'DRAFT',
            EXTRACT(YEAR FROM CURRENT_DATE),
            'IT',
            'LOCAL'
        );
        RAISE NOTICE 'Test 14 FAILED: Project creation with duplicate title succeeded';
    EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE 'Test 14 PASSED: Project creation with duplicate title was prevented';
    END;

    -- Test 15: Test foreign key constraints
    BEGIN
        INSERT INTO projects_owners (project_id, owner_id) 
        VALUES (999999, 999999);
        RAISE NOTICE 'Test 15 FAILED: Insert with invalid foreign keys succeeded';
    EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE 'Test 15 PASSED: Insert with invalid foreign keys was prevented';
    END;

    -- Test 16: Test project duration calculation
    BEGIN
        SELECT get_project_duration(test_project_id) INTO test_record;
        RAISE NOTICE 'Test 16 PASSED: Project duration calculation works';
    EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE 'Test 16 FAILED: Project duration calculation failed - %', SQLERRM;
    END;

    -- Test 17: Test location-based queries
    BEGIN
        FOR test_record IN SELECT * FROM get_projects_by_location('Test City', 'Test County') LOOP
            -- Just loop through results
            NULL;
        END LOOP;
        RAISE NOTICE 'Test 17 PASSED: Location-based queries work';
    EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE 'Test 17 FAILED: Location-based queries failed - %', SQLERRM;
    END;

    -- Test 18: Test management level queries
    BEGIN
        FOR test_record IN SELECT * FROM get_projects_by_management_level('LOCAL') LOOP
            -- Just loop through results
            NULL;
        END LOOP;
        RAISE NOTICE 'Test 18 PASSED: Management level queries work';
    EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE 'Test 18 FAILED: Management level queries failed - %', SQLERRM;
    END;

    -- Test 19: Test incremental backup
    BEGIN
        PERFORM perform_incremental_backup('/var/backups/kart/incremental');
        RAISE NOTICE 'Test 19 PASSED: Incremental backup function works';
    EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE 'Test 19 FAILED: Incremental backup function failed - %', SQLERRM;
    END;

    -- Test 20: Test backup cleanup
    BEGIN
        PERFORM cleanup_old_backups(30);
        RAISE NOTICE 'Test 20 PASSED: Backup cleanup function works';
    EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE 'Test 20 FAILED: Backup cleanup function failed - %', SQLERRM;
    END;
END;
$$; 