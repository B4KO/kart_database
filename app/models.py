from sqlalchemy import Boolean, Column, ForeignKey, Integer, String, DateTime, Enum, Text, Table
from sqlalchemy.orm import relationship
from datetime import datetime
from .database import Base
import enum

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    username = Column(String, unique=True, index=True)
    email = Column(String, unique=True, index=True)
    hashed_password = Column(String)
    role = Column(String)  # Using roles enum from database

class ProjectStatus(str, enum.Enum):
    DRAFT = "DRAFT"
    IN_PROGRESS = "IN_PROGRESS"
    COMPLETED = "COMPLETED"
    ON_HOLD = "ON_HOLD"
    CANCELLED = "CANCELLED"
    POSTPONED = "POSTPONED"

class ProjectSector(str, enum.Enum):
    IT = "IT"
    ECONOMY = "ECONOMY"
    ENVIRONMENT = "ENVIRONMENT"
    SOCIETY = "SOCIETY"
    GOVERNMENT = "GOVERNMENT"
    HEALTH = "HEALTH"
    EDUCATION = "EDUCATION"
    INNOVATION = "INNOVATION"
    OTHER = "OTHER"

class ProjectManagementLevel(str, enum.Enum):
    NATIONAL = "NATIONAL"
    REGIONAL = "REGIONAL"
    LOCAL = "LOCAL"

class Project(Base):
    __tablename__ = "projects"

    id = Column(Integer, primary_key=True, index=True)
    title = Column(String, unique=True, index=True)
    description = Column(Text)
    status = Column(Enum(ProjectStatus), default=ProjectStatus.DRAFT)
    start_year = Column(Integer)
    end_year = Column(Integer)
    sector = Column(Enum(ProjectSector))
    project_link = Column(String)
    notes = Column(Text)
    managment_level = Column(Enum(ProjectManagementLevel))
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    owners = relationship("Owner", secondary="projects_owners", back_populates="projects")
    contacts = relationship("Contact", secondary="projects_contacts", back_populates="projects")
    locations = relationship("Location", secondary="projects_locations", back_populates="projects")
    cooperators = relationship("Cooperator", secondary="projects_cooperators", back_populates="projects")
    benefits = relationship("Benefit", secondary="projects_benefits", back_populates="projects")

class Owner(Base):
    __tablename__ = "owners"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, index=True)
    description = Column(Text)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    projects = relationship("Project", secondary="projects_owners", back_populates="owners")

class Cooperator(Base):
    __tablename__ = "cooperators"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, index=True)

    projects = relationship("Project", secondary="projects_cooperators", back_populates="cooperators")

class Benefit(Base):
    __tablename__ = "benefits"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, index=True)
    description = Column(Text)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    projects = relationship("Project", secondary="projects_benefits", back_populates="benefits")

class Address(Base):
    __tablename__ = "addresses"

    id = Column(Integer, primary_key=True, index=True)
    city = Column(String)
    county = Column(String)
    postal_code = Column(String)

    locations = relationship("Location", back_populates="address")

class Contact(Base):
    __tablename__ = "contacts"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String)
    email = Column(String, unique=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    projects = relationship("Project", secondary="projects_contacts", back_populates="contacts")

class Location(Base):
    __tablename__ = "locations"

    id = Column(Integer, primary_key=True, index=True)
    address_id = Column(Integer, ForeignKey("addresses.id"))
    name = Column(String)
    description = Column(Text)

    address = relationship("Address", back_populates="locations")
    projects = relationship("Project", secondary="projects_locations", back_populates="locations")

# Association tables
projects_owners = Table(
    "projects_owners",
    Base.metadata,
    Column("project_id", Integer, ForeignKey("projects.id"), primary_key=True),
    Column("owner_id", Integer, ForeignKey("owners.id"), primary_key=True)
)

projects_contacts = Table(
    "projects_contacts",
    Base.metadata,
    Column("project_id", Integer, ForeignKey("projects.id"), primary_key=True),
    Column("contact_id", Integer, ForeignKey("contacts.id"), primary_key=True)
)

projects_locations = Table(
    "projects_locations",
    Base.metadata,
    Column("project_id", Integer, ForeignKey("projects.id"), primary_key=True),
    Column("location_id", Integer, ForeignKey("locations.id"), primary_key=True)
)

projects_cooperators = Table(
    "projects_cooperators",
    Base.metadata,
    Column("project_id", Integer, ForeignKey("projects.id"), primary_key=True),
    Column("cooperator_id", Integer, ForeignKey("cooperators.id"), primary_key=True)
)

projects_benefits = Table(
    "projects_benefits",
    Base.metadata,
    Column("project_id", Integer, ForeignKey("projects.id"), primary_key=True),
    Column("benefit_id", Integer, ForeignKey("benefits.id"), primary_key=True)
) 