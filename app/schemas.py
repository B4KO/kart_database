from pydantic import BaseModel, EmailStr
from typing import Optional, List
from datetime import datetime
from .models import ProjectStatus

# User schemas
class UserBase(BaseModel):
    username: str
    email: EmailStr
    role: str

class UserCreate(UserBase):
    password: str

class User(UserBase):
    id: int
    is_active: bool

    class Config:
        from_attributes = True

# Token schemas
class Token(BaseModel):
    access_token: str
    token_type: str

class TokenData(BaseModel):
    username: Optional[str] = None

class LoginForm(BaseModel):
    username: str
    password: str

# Project schemas
class ProjectBase(BaseModel):
    name: str
    description: Optional[str] = None
    status: ProjectStatus
    start_date: datetime
    end_date: Optional[datetime] = None
    department_id: int
    digital_network_id: int
    address_id: int
    contact_id: int

class ProjectCreate(ProjectBase):
    pass

class ProjectUpdate(BaseModel):
    name: Optional[str] = None
    description: Optional[str] = None
    status: Optional[ProjectStatus] = None
    start_date: Optional[datetime] = None
    end_date: Optional[datetime] = None
    department_id: Optional[int] = None
    digital_network_id: Optional[int] = None
    address_id: Optional[int] = None
    contact_id: Optional[int] = None
    is_active: Optional[bool] = None

class Project(ProjectBase):
    id: int
    is_active: bool
    created_at: datetime
    updated_at: datetime
    organizations: List["Organization"] = []

    class Config:
        from_attributes = True

# Organization schemas
class OrganizationBase(BaseModel):
    name: str
    description: Optional[str] = None
    owner_type_id: int

class OrganizationCreate(OrganizationBase):
    pass

class Organization(OrganizationBase):
    id: int
    is_active: bool
    created_at: datetime
    updated_at: datetime
    projects: List[Project] = []

    class Config:
        from_attributes = True

# Department schemas
class DepartmentBase(BaseModel):
    name: str
    description: Optional[str] = None

class DepartmentCreate(DepartmentBase):
    pass

class Department(DepartmentBase):
    id: int
    is_active: bool
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True

# DigitalNetwork schemas
class DigitalNetworkBase(BaseModel):
    name: str
    description: Optional[str] = None

class DigitalNetworkCreate(DigitalNetworkBase):
    pass

class DigitalNetwork(DigitalNetworkBase):
    id: int
    is_active: bool
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True

# Address schemas
class AddressBase(BaseModel):
    street: str
    city: str
    state: str
    postal_code: str
    country: str

class AddressCreate(AddressBase):
    pass

class Address(AddressBase):
    id: int
    is_active: bool
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True

# Contact schemas
class ContactBase(BaseModel):
    name: str
    email: EmailStr
    phone: str

class ContactCreate(ContactBase):
    pass

class Contact(ContactBase):
    id: int
    is_active: bool
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True

# OwnerType schemas
class OwnerTypeBase(BaseModel):
    name: str
    description: Optional[str] = None

class OwnerTypeCreate(OwnerTypeBase):
    pass

class OwnerType(OwnerTypeBase):
    id: int
    is_active: bool
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True 