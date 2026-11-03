import pytest
from fastapi import HTTPException

from app.features.auth.schemas import UserLogin, UserSignup
from app.features.auth.service import authenticate_user, create_user


def test_signup_and_login_service(db) -> None:
    # 1. Signup
    signup_payload = UserSignup(
        name="Alex Rivera",
        email="alex@example.com",
        password="securepassword123",
    )
    user = create_user(db, signup_payload)
    assert user.name == "Alex Rivera"
    assert user.email == "alex@example.com"
    assert user.token is not None

    # 2. Duplicate signup should raise 400
    with pytest.raises(HTTPException) as exc_info:
        create_user(db, signup_payload)
    assert exc_info.value.status_code == 400

    # 3. Successful login
    login_payload = UserLogin(email="alex@example.com", password="securepassword123")
    logged_in = authenticate_user(db, login_payload)
    assert logged_in.email == "alex@example.com"
    assert logged_in.token is not None

    # 4. Invalid credentials raise 401
    with pytest.raises(HTTPException) as exc_info:
        authenticate_user(
            db,
            UserLogin(email="alex@example.com", password="wrongpassword"),
        )
    assert exc_info.value.status_code == 401
