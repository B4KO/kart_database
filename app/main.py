from fastapi import FastAPI, Depends, HTTPException, status, Form
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session
from typing import List
import uvicorn

from .database import SessionLocal, engine, get_db
from . import models, schemas, crud
from .auth import get_current_user

app = FastAPI(
    title="KART Database API",
    description="API for managing KART database operations",
    version="1.0.0"
)

# Configure CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, replace with specific origins
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
async def root():
    return {"message": "Welcome to KART Database API"}

# Projects endpoints
@app.get("/projects/", response_model=List[schemas.Project])
def read_projects(
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    projects = crud.get_projects(db, skip=skip, limit=limit)
    return projects

@app.post("/projects/", response_model=schemas.Project)
def create_project(
    project: schemas.ProjectCreate,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    return crud.create_project(db=db, project=project)

@app.get("/projects/{project_id}", response_model=schemas.Project)
def read_project(
    project_id: int,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    project = crud.get_project(db, project_id=project_id)
    if project is None:
        raise HTTPException(status_code=404, detail="Project not found")
    return project

@app.put("/projects/{project_id}", response_model=schemas.Project)
def update_project(
    project_id: int,
    project: schemas.ProjectUpdate,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    updated_project = crud.update_project(db, project_id=project_id, project=project)
    if updated_project is None:
        raise HTTPException(status_code=404, detail="Project not found")
    return updated_project

@app.delete("/projects/{project_id}")
def delete_project(
    project_id: int,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    success = crud.delete_project(db, project_id=project_id)
    if not success:
        raise HTTPException(status_code=404, detail="Project not found")
    return {"message": "Project deleted successfully"}

# Owners endpoints
@app.get("/owners/", response_model=List[schemas.Owner])
def read_owners(
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    owners = crud.get_owners(db, skip=skip, limit=limit)
    return owners

@app.post("/owners/", response_model=schemas.Owner)
def create_owner(
    owner: schemas.OwnerCreate,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    return crud.create_owner(db=db, owner=owner)

@app.get("/owners/{owner_id}", response_model=schemas.Owner)
def read_owner(
    owner_id: int,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    owner = crud.get_owner(db, owner_id=owner_id)
    if owner is None:
        raise HTTPException(status_code=404, detail="Owner not found")
    return owner

@app.put("/owners/{owner_id}", response_model=schemas.Owner)
def update_owner(
    owner_id: int,
    owner: schemas.OwnerCreate,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    updated_owner = crud.update_owner(db, owner_id=owner_id, owner=owner)
    if updated_owner is None:
        raise HTTPException(status_code=404, detail="Owner not found")
    return updated_owner

@app.delete("/owners/{owner_id}")
def delete_owner(
    owner_id: int,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    success = crud.delete_owner(db, owner_id=owner_id)
    if not success:
        raise HTTPException(status_code=404, detail="Owner not found")
    return {"message": "Owner deleted successfully"}

# Cooperators endpoints
@app.get("/cooperators/", response_model=List[schemas.Cooperator])
def read_cooperators(
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    cooperators = crud.get_cooperators(db, skip=skip, limit=limit)
    return cooperators

@app.post("/cooperators/", response_model=schemas.Cooperator)
def create_cooperator(
    cooperator: schemas.CooperatorCreate,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    return crud.create_cooperator(db=db, cooperator=cooperator)

# Benefits endpoints
@app.get("/benefits/", response_model=List[schemas.Benefit])
def read_benefits(
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    benefits = crud.get_benefits(db, skip=skip, limit=limit)
    return benefits

@app.post("/benefits/", response_model=schemas.Benefit)
def create_benefit(
    benefit: schemas.BenefitCreate,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    return crud.create_benefit(db=db, benefit=benefit)

# Addresses endpoints
@app.get("/addresses/", response_model=List[schemas.Address])
def read_addresses(
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    addresses = crud.get_addresses(db, skip=skip, limit=limit)
    return addresses

@app.post("/addresses/", response_model=schemas.Address)
def create_address(
    address: schemas.AddressCreate,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    return crud.create_address(db=db, address=address)

# Contacts endpoints
@app.get("/contacts/", response_model=List[schemas.Contact])
def read_contacts(
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    contacts = crud.get_contacts(db, skip=skip, limit=limit)
    return contacts

@app.post("/contacts/", response_model=schemas.Contact)
def create_contact(
    contact: schemas.ContactCreate,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    return crud.create_contact(db=db, contact=contact)

# Locations endpoints
@app.get("/locations/", response_model=List[schemas.Location])
def read_locations(
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    locations = crud.get_locations(db, skip=skip, limit=limit)
    return locations

@app.post("/locations/", response_model=schemas.Location)
def create_location(
    location: schemas.LocationCreate,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    return crud.create_location(db=db, location=location)

# Authentication endpoints
@app.post("/token", response_model=schemas.Token)
async def login_for_access_token(
    username: str = Form(...),
    password: str = Form(...),
    db: Session = Depends(get_db)
):
    user = crud.authenticate_user(db, username, password)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect username or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    access_token = crud.create_access_token(data={"sub": user.username})
    return {"access_token": access_token, "token_type": "bearer"}

if __name__ == "__main__":
    # Create database tables
    models.Base.metadata.create_all(bind=engine)
    uvicorn.run("app.main:app", host="0.0.0.0", port=8000, reload=True) 