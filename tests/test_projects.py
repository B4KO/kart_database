import pytest
from datetime import datetime
from app import models
from app.schemas import ProjectCreate, ProjectUpdate

def test_create_project(client, db_session):
    # Create necessary related records first
    department = models.Department(name="Test Department", description="Test Description")
    digital_network = models.DigitalNetwork(name="Test Network", description="Test Description")
    address = models.Address(
        street="123 Test St",
        city="Test City",
        state="TS",
        postal_code="12345",
        country="Test Country"
    )
    contact = models.Contact(
        name="Test Contact",
        email="contact@test.com",
        phone="123-456-7890"
    )
    
    db_session.add_all([department, digital_network, address, contact])
    db_session.commit()
    
    project_data = {
        "name": "Test Project",
        "description": "Test Description",
        "status": "planned",
        "start_date": "2024-01-01T00:00:00",
        "end_date": "2024-12-31T00:00:00",
        "department_id": department.id,
        "digital_network_id": digital_network.id,
        "address_id": address.id,
        "contact_id": contact.id
    }
    
    response = client.post("/projects/", json=project_data)
    assert response.status_code == 200
    data = response.json()
    assert data["name"] == project_data["name"]
    assert data["description"] == project_data["description"]
    assert data["status"] == project_data["status"]

def test_read_projects(client, db_session):
    # Create a test project
    project = models.Project(
        name="Test Project",
        description="Test Description",
        status="planned",
        start_date=datetime(2024, 1, 1),
        end_date=datetime(2024, 12, 31)
    )
    db_session.add(project)
    db_session.commit()
    
    response = client.get("/projects/")
    assert response.status_code == 200
    data = response.json()
    assert len(data) > 0
    assert data[0]["name"] == "Test Project"

def test_read_project(client, db_session):
    # Create a test project
    project = models.Project(
        name="Test Project",
        description="Test Description",
        status="planned",
        start_date=datetime(2024, 1, 1),
        end_date=datetime(2024, 12, 31)
    )
    db_session.add(project)
    db_session.commit()
    
    response = client.get(f"/projects/{project.id}")
    assert response.status_code == 200
    data = response.json()
    assert data["name"] == "Test Project"
    assert data["id"] == project.id

def test_update_project(client, db_session):
    # Create a test project
    project = models.Project(
        name="Test Project",
        description="Test Description",
        status="planned",
        start_date=datetime(2024, 1, 1),
        end_date=datetime(2024, 12, 31)
    )
    db_session.add(project)
    db_session.commit()
    
    update_data = {
        "name": "Updated Project",
        "description": "Updated Description",
        "status": "in_progress"
    }
    
    response = client.put(f"/projects/{project.id}", json=update_data)
    assert response.status_code == 200
    data = response.json()
    assert data["name"] == update_data["name"]
    assert data["description"] == update_data["description"]
    assert data["status"] == update_data["status"]

def test_delete_project(client, db_session):
    # Create a test project
    project = models.Project(
        name="Test Project",
        description="Test Description",
        status="planned",
        start_date=datetime(2024, 1, 1),
        end_date=datetime(2024, 12, 31)
    )
    db_session.add(project)
    db_session.commit()
    
    response = client.delete(f"/projects/{project.id}")
    assert response.status_code == 200
    assert response.json()["message"] == "Project deleted successfully"
    
    # Verify the project is deleted
    deleted_project = db_session.query(models.Project).filter(models.Project.id == project.id).first()
    assert deleted_project is None 