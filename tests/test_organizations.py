import pytest
from datetime import datetime
from app import models

def test_create_organization(client, db_session):
    # Create necessary related records first
    owner_type = models.OwnerType(name="Test Owner Type", description="Test Description")
    db_session.add(owner_type)
    db_session.commit()
    
    organization_data = {
        "name": "Test Organization",
        "description": "Test Description",
        "owner_type_id": owner_type.id
    }
    
    response = client.post("/organizations/", json=organization_data)
    assert response.status_code == 200
    data = response.json()
    assert data["name"] == organization_data["name"]
    assert data["description"] == organization_data["description"]
    assert data["owner_type_id"] == owner_type.id

def test_read_organizations(client, db_session):
    # Create a test organization
    owner_type = models.OwnerType(name="Test Owner Type", description="Test Description")
    db_session.add(owner_type)
    db_session.commit()
    
    organization = models.Organization(
        name="Test Organization",
        description="Test Description",
        owner_type_id=owner_type.id
    )
    db_session.add(organization)
    db_session.commit()
    
    response = client.get("/organizations/")
    assert response.status_code == 200
    data = response.json()
    assert len(data) > 0
    assert data[0]["name"] == "Test Organization"
    assert data[0]["owner_type_id"] == owner_type.id 