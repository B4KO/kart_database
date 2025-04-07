import pytest
import os
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.pool import StaticPool

# Set test database URL before importing app modules
os.environ["TEST_DATABASE_URL"] = "sqlite:///:memory:"

from app.main import app
from app.database import Base, get_db
from app import models
from app.auth import get_current_user

# Create test database
SQLALCHEMY_DATABASE_URL = os.environ["TEST_DATABASE_URL"]
engine = create_engine(
    SQLALCHEMY_DATABASE_URL,
    connect_args={"check_same_thread": False},
    poolclass=StaticPool,
)
TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# Override the get_db dependency
def override_get_db():
    try:
        db = TestingSessionLocal()
        yield db
    finally:
        db.close()

# Override the get_current_user dependency
def override_get_current_user():
    return models.User(
        id=1,
        username="testuser",
        email="test@example.com",
        hashed_password="hashed_password",
        is_active=True,
        role="kart_admin"
    )

@pytest.fixture(scope="session")
def test_db():
    # Create all tables
    Base.metadata.create_all(bind=engine)
    yield engine
    # Drop all tables
    Base.metadata.drop_all(bind=engine)

@pytest.fixture(scope="function")
def db_session(test_db):
    connection = test_db.connect()
    transaction = connection.begin()
    session = TestingSessionLocal(bind=connection)
    
    yield session
    
    session.close()
    transaction.rollback()
    connection.close()

@pytest.fixture(scope="function")
def client(db_session):
    # Override the database dependency
    app.dependency_overrides[get_db] = lambda: db_session
    app.dependency_overrides[get_current_user] = override_get_current_user
    
    with TestClient(app) as test_client:
        yield test_client
    
    # Clear the overrides
    app.dependency_overrides.clear() 