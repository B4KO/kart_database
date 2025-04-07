import pytest
from datetime import datetime
from app import models
from app.schemas import ProjectCreate, ProjectUpdate

def test_create_project(client, db_session):
    # Create necessary related records first
    owner = models.Owner(name="Test Owner", description="Test Description")
    address = models.Address(
        city="Test City",
        county="Test County",
        postal_code="12345"
    )
    contact = models.Contact(
        name="Test Contact",
        email="contact@test.com"
    )
    
    db_session.add_all([owner, address, contact])
    db_session.commit()

    # Create a location linked to the address
    location = models.Location(
        name="Test Location",
        description="Test Location Description",
        address_id=address.id
    )
    db_session.add(location)
    db_session.commit()
    
    project_data = {
        "title": "Test Project",
        "description": "Test Description",
        "status": "DRAFT",
        "start_year": 2024,
        "end_year": 2024,
        "sector": "IT",
        "project_link": "https://test.com",
        "notes": "Test notes",
        "managment_level": "NATIONAL"
    }
    
    response = client.post("/projects/", json=project_data)
    assert response.status_code == 200
    data = response.json()
    assert data["title"] == project_data["title"]
    assert data["description"] == project_data["description"]
    assert data["status"] == project_data["status"]
    assert data["sector"] == project_data["sector"]
    assert data["managment_level"] == project_data["managment_level"]

def test_read_projects(client, db_session):
    # Create a test project
    project = models.Project(
        title="Test Project",
        description="Test Description",
        status="DRAFT",
        start_year=2024,
        end_year=2024,
        sector="IT",
        project_link="https://test.com",
        notes="Test notes",
        managment_level="NATIONAL"
    )
    db_session.add(project)
    db_session.commit()
    
    response = client.get("/projects/")
    assert response.status_code == 200
    data = response.json()
    assert len(data) > 0
    assert data[0]["title"] == "Test Project"

def test_read_project(client, db_session):
    # Create a test project
    project = models.Project(
        title="Test Project",
        description="Test Description",
        status="DRAFT",
        start_year=2024,
        end_year=2024,
        sector="IT",
        project_link="https://test.com",
        notes="Test notes",
        managment_level="NATIONAL"
    )
    db_session.add(project)
    db_session.commit()
    
    response = client.get(f"/projects/{project.id}")
    assert response.status_code == 200
    data = response.json()
    assert data["title"] == "Test Project"
    assert data["id"] == project.id

def test_update_project(client, db_session):
    # Create a test project
    project = models.Project(
        title="Test Project",
        description="Test Description",
        status="DRAFT",
        start_year=2024,
        end_year=2024,
        sector="IT",
        project_link="https://test.com",
        notes="Test notes",
        managment_level="NATIONAL"
    )
    db_session.add(project)
    db_session.commit()
    
    update_data = {
        "title": "Updated Project",
        "description": "Updated Description",
        "status": "IN_PROGRESS",
        "sector": "ECONOMY",
        "managment_level": "REGIONAL"
    }
    
    response = client.put(f"/projects/{project.id}", json=update_data)
    assert response.status_code == 200
    data = response.json()
    assert data["title"] == update_data["title"]
    assert data["description"] == update_data["description"]
    assert data["status"] == update_data["status"]
    assert data["sector"] == update_data["sector"]
    assert data["managment_level"] == update_data["managment_level"]

def test_delete_project(client, db_session):
    # Create a test project
    project = models.Project(
        title="Test Project",
        description="Test Description",
        status="DRAFT",
        start_year=2024,
        end_year=2024,
        sector="IT",
        project_link="https://test.com",
        notes="Test notes",
        managment_level="NATIONAL"
    )
    db_session.add(project)
    db_session.commit()
    
    response = client.delete(f"/projects/{project.id}")
    assert response.status_code == 200
    assert response.json()["message"] == "Project deleted successfully"
    
    # Verify the project is deleted
    deleted_project = db_session.query(models.Project).filter(models.Project.id == project.id).first()
    assert deleted_project is None 