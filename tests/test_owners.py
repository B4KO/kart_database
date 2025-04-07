import pytest
from datetime import datetime
from app import models

def test_create_owner(client, db_session):
    owner_data = {
        "name": "Test Owner",
        "description": "Test Description"
    }
    
    response = client.post("/owners/", json=owner_data)
    assert response.status_code == 200
    data = response.json()
    assert data["name"] == owner_data["name"]
    assert data["description"] == owner_data["description"]

def test_read_owners(client, db_session):
    # Create a test owner
    owner = models.Owner(
        name="Test Owner",
        description="Test Description"
    )
    db_session.add(owner)
    db_session.commit()
    
    response = client.get("/owners/")
    assert response.status_code == 200
    data = response.json()
    assert len(data) > 0
    assert data[0]["name"] == "Test Owner"
    assert data[0]["description"] == "Test Description" 