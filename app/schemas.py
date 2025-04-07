from pydantic import BaseModel, EmailStr, ConfigDict
from typing import Optional, List
from datetime import datetime
from .models import ProjectStatus, ProjectSector, ProjectManagementLevel, UserRole

# User schemas
class UserBase(BaseModel):
    username: str
    email: EmailStr
    role: UserRole

class UserCreate(UserBase):
    password: str

class User(UserBase):
    id: int
    model_config = ConfigDict(from_attributes=True)

# Token schemas
class Token(BaseModel):
    access_token: str
    token_type: str

class TokenData(BaseModel):
    username: Optional[str] = None

# Project schemas
class ProjectBase(BaseModel):
    title: str
    description: Optional[str] = None
    status: ProjectStatus = ProjectStatus.DRAFT
    start_year: int
    end_year: Optional[int] = None
    sector: ProjectSector
    project_link: Optional[str] = None
    notes: Optional[str] = None
    managment_level: ProjectManagementLevel

class ProjectCreate(ProjectBase):
    pass

class ProjectUpdate(BaseModel):
    title: Optional[str] = None
    description: Optional[str] = None
    status: Optional[ProjectStatus] = None
    start_year: Optional[int] = None
    end_year: Optional[int] = None
    sector: Optional[ProjectSector] = None
    project_link: Optional[str] = None
    notes: Optional[str] = None
    managment_level: Optional[ProjectManagementLevel] = None

class Project(ProjectBase):
    id: int
    created_at: datetime
    updated_at: datetime
    model_config = ConfigDict(from_attributes=True)

# Owner schemas
class OwnerBase(BaseModel):
    name: str
    description: Optional[str] = None

class OwnerCreate(OwnerBase):
    pass

class Owner(OwnerBase):
    id: int
    created_at: datetime
    updated_at: datetime
    model_config = ConfigDict(from_attributes=True)

# Cooperator schemas
class CooperatorBase(BaseModel):
    name: str

class CooperatorCreate(CooperatorBase):
    pass

class Cooperator(CooperatorBase):
    id: int
    model_config = ConfigDict(from_attributes=True)

# Benefit schemas
class BenefitBase(BaseModel):
    name: str
    description: Optional[str] = None

class BenefitCreate(BenefitBase):
    pass

class Benefit(BenefitBase):
    id: int
    created_at: datetime
    updated_at: datetime
    model_config = ConfigDict(from_attributes=True)

# Address schemas
class AddressBase(BaseModel):
    city: str
    county: str
    postal_code: str

class AddressCreate(AddressBase):
    pass

class Address(AddressBase):
    id: int
    model_config = ConfigDict(from_attributes=True)

# Contact schemas
class ContactBase(BaseModel):
    name: str
    email: EmailStr

class ContactCreate(ContactBase):
    pass

class Contact(ContactBase):
    id: int
    created_at: datetime
    updated_at: datetime
    model_config = ConfigDict(from_attributes=True)

# Location schemas
class LocationBase(BaseModel):
    name: str
    description: Optional[str] = None
    address_id: int

class LocationCreate(LocationBase):
    pass

class Location(LocationBase):
    id: int
    model_config = ConfigDict(from_attributes=True) 