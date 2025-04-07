from sqlalchemy import create_engine
from sqlalchemy.orm import declarative_base, sessionmaker
import os
from dotenv import load_dotenv
from fastapi import Depends
from sqlalchemy.orm import Session

load_dotenv()

# Use SQLite for testing, PostgreSQL for production
SQLALCHEMY_DATABASE_URL = os.getenv(
    "TEST_DATABASE_URL",  # Use test database URL if set
    os.getenv(
        "DATABASE_URL",
        "sqlite:///./test.db"  # Default to SQLite for testing
    )
)

engine = create_engine(SQLALCHEMY_DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

Base = declarative_base()

# Dependency
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

def init_db():
    # Import here to avoid circular imports
    from . import models
    from .auth import get_password_hash
    
    # Create all tables
    Base.metadata.create_all(bind=engine)
    
    # Initialize default users if they don't exist
    db = SessionLocal()
    try:
        # Check if any users exist
        if db.query(models.User).first() is None:
            # Create default users
            default_users = [
                {
                    "email": "admin@kart.com",
                    "username": "admin",
                    "password": "admin123",
                    "role": models.UserRole.ADMIN
                },
                {
                    "email": "pm1@kart.com",
                    "username": "pm1",
                    "password": "manager123",
                    "role": models.UserRole.USER
                },
                {
                    "email": "pm2@kart.com",
                    "username": "pm2",
                    "password": "manager123",
                    "role": models.UserRole.USER
                },
                {
                    "email": "analyst1@kart.com",
                    "username": "analyst1",
                    "password": "analyst123",
                    "role": models.UserRole.USER
                },
                {
                    "email": "analyst2@kart.com",
                    "username": "analyst2",
                    "password": "analyst123",
                    "role": models.UserRole.USER
                },
                {
                    "email": "viewer1@kart.com",
                    "username": "viewer1",
                    "password": "viewer123",
                    "role": models.UserRole.USER
                },
                {
                    "email": "viewer2@kart.com",
                    "username": "viewer2",
                    "password": "viewer123",
                    "role": models.UserRole.USER
                }
            ]
            
            for user_data in default_users:
                user = models.User(
                    email=user_data["email"],
                    username=user_data["username"],
                    hashed_password=get_password_hash(user_data["password"]),
                    role=user_data["role"]
                )
                db.add(user)
            
            db.commit()
    except Exception as e:
        print(f"Error initializing database: {e}")
        db.rollback()
    finally:
        db.close() 