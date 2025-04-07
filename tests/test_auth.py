import pytest
from app import models
from app.auth import get_password_hash

def test_login_for_access_token(client, db_session):
    # Create a test user
    user = models.User(
        username="testuser",
        email="test@example.com",
        hashed_password=get_password_hash("testpassword"),
        is_active=True,
        role="kart_admin"
    )
    db_session.add(user)
    db_session.commit()
    
    login_data = {
        "username": "testuser",
        "password": "testpassword"
    }
    
    response = client.post("/token", data=login_data)
    assert response.status_code == 200
    data = response.json()
    assert "access_token" in data
    assert data["token_type"] == "bearer"

def test_login_invalid_credentials(client, db_session):
    # Create a test user
    user = models.User(
        username="testuser",
        email="test@example.com",
        hashed_password=get_password_hash("testpassword"),
        is_active=True,
        role="kart_admin"
    )
    db_session.add(user)
    db_session.commit()
    
    login_data = {
        "username": "testuser",
        "password": "wrongpassword"
    }
    
    response = client.post("/token", data=login_data)
    assert response.status_code == 401
    assert response.json()["detail"] == "Incorrect username or password"

def test_login_inactive_user(client, db_session):
    # Create an inactive test user
    user = models.User(
        username="inactiveuser",
        email="inactive@example.com",
        hashed_password=get_password_hash("testpassword"),
        is_active=False,
        role="kart_admin"
    )
    db_session.add(user)
    db_session.commit()
    
    login_data = {
        "username": "inactiveuser",
        "password": "testpassword"
    }
    
    response = client.post("/token", data=login_data)
    assert response.status_code == 401
    assert response.json()["detail"] == "Incorrect username or password" 