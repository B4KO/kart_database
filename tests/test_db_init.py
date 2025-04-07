import pytest
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from app.database import Base, init_db, engine
from app import models
from app.auth import verify_password

# Create a test database session
TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

@pytest.fixture(scope="function")
def db_session():
    # Create all tables
    Base.metadata.create_all(bind=engine)
    
    # Create a new session
    db = TestingSessionLocal()
    try:
        yield db
    finally:
        db.close()
        # Drop all tables
        Base.metadata.drop_all(bind=engine)

def test_database_initialization(db_session):
    # Initialize the database
    init_db()
    
    # Test if users were created
    users = db_session.query(models.User).all()
    assert len(users) == 7, "Should have created 7 default users"
    
    # Test admin user
    admin = db_session.query(models.User).filter(models.User.username == "admin").first()
    assert admin is not None, "Admin user should exist"
    assert admin.email == "admin@kart.com", "Admin email should be correct"
    assert admin.role == "ADMIN", "Admin role should be correct"
    assert verify_password("admin123", admin.hashed_password), "Admin password should be correct"
    
    # Test project manager users
    pm1 = db_session.query(models.User).filter(models.User.username == "pm1").first()
    assert pm1 is not None, "PM1 user should exist"
    assert pm1.email == "pm1@kart.com", "PM1 email should be correct"
    assert pm1.role == "USER", "PM1 role should be correct"
    assert verify_password("manager123", pm1.hashed_password), "PM1 password should be correct"
    
    pm2 = db_session.query(models.User).filter(models.User.username == "pm2").first()
    assert pm2 is not None, "PM2 user should exist"
    assert pm2.email == "pm2@kart.com", "PM2 email should be correct"
    assert pm2.role == "USER", "PM2 role should be correct"
    assert verify_password("manager123", pm2.hashed_password), "PM2 password should be correct"
    
    # Test analyst users
    analyst1 = db_session.query(models.User).filter(models.User.username == "analyst1").first()
    assert analyst1 is not None, "Analyst1 user should exist"
    assert analyst1.email == "analyst1@kart.com", "Analyst1 email should be correct"
    assert analyst1.role == "USER", "Analyst1 role should be correct"
    assert verify_password("analyst123", analyst1.hashed_password), "Analyst1 password should be correct"
    
    analyst2 = db_session.query(models.User).filter(models.User.username == "analyst2").first()
    assert analyst2 is not None, "Analyst2 user should exist"
    assert analyst2.email == "analyst2@kart.com", "Analyst2 email should be correct"
    assert analyst2.role == "USER", "Analyst2 role should be correct"
    assert verify_password("analyst123", analyst2.hashed_password), "Analyst2 password should be correct"
    
    # Test viewer users
    viewer1 = db_session.query(models.User).filter(models.User.username == "viewer1").first()
    assert viewer1 is not None, "Viewer1 user should exist"
    assert viewer1.email == "viewer1@kart.com", "Viewer1 email should be correct"
    assert viewer1.role == "USER", "Viewer1 role should be correct"
    assert verify_password("viewer123", viewer1.hashed_password), "Viewer1 password should be correct"
    
    viewer2 = db_session.query(models.User).filter(models.User.username == "viewer2").first()
    assert viewer2 is not None, "Viewer2 user should exist"
    assert viewer2.email == "viewer2@kart.com", "Viewer2 email should be correct"
    assert viewer2.role == "USER", "Viewer2 role should be correct"
    assert verify_password("viewer123", viewer2.hashed_password), "Viewer2 password should be correct"
    
    # Test uniqueness of usernames and emails
    usernames = [user.username for user in users]
    emails = [user.email for user in users]
    assert len(usernames) == len(set(usernames)), "Usernames should be unique"
    assert len(emails) == len(set(emails)), "Emails should be unique"

def test_database_initialization_idempotency(db_session):
    # Initialize the database twice
    init_db()
    init_db()
    
    # Test if we still have exactly 7 users after double initialization
    users = db_session.query(models.User).all()
    assert len(users) == 7, "Double initialization should not create duplicate users" 