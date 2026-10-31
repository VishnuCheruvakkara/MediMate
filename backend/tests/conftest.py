import pytest
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

from app.core.database import Base

test_engine = create_engine("sqlite:///:memory:")
TestSession = sessionmaker(bind=test_engine, expire_on_commit=False)


@pytest.fixture(autouse=True)
def clean_database():
    Base.metadata.create_all(bind=test_engine)
    yield
    Base.metadata.drop_all(bind=test_engine)


@pytest.fixture
def db():
    with TestSession() as session:
        yield session

