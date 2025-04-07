from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
import os
from dotenv import load_dotenv
from fastapi import Depends
from sqlalchemy.orm import Session

load_dotenv()

# Allow test configuration to override the database URL
SQLALCHEMY_DATABASE_URL = os.getenv(
    "TEST_DATABASE_URL",  # Use test database URL if set
    os.getenv(
        "DATABASE_URL",
        "postgresql://kart_admin:CHANGE_ADMIN_PASSWORD@localhost:5432/kart_database"
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