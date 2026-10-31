from datetime import datetime
from enum import StrEnum
from uuid import UUID

from pydantic import BaseModel, ConfigDict, Field, field_validator


class MeasurementMethod(StrEnum):
    ORAL = "oral"
    AXILLARY = "axillary"
    TYMPANIC = "tympanic"
    TEMPORAL = "temporal"
    RECTAL = "rectal"
    OTHER = "other"


class FeverEntryCreate(BaseModel):
    temperature_c: float = Field(ge=30, le=45)
    measured_at: datetime
    measurement_method: MeasurementMethod = MeasurementMethod.OTHER
    symptoms: list[str] = Field(default_factory=list, max_length=20)
    notes: str | None = Field(default=None, max_length=1000)
    medicine_taken: bool = False

    @field_validator("measured_at")
    @classmethod
    def require_timezone(cls, value: datetime) -> datetime:
        if value.tzinfo is None or value.utcoffset() is None:
            raise ValueError("measured_at must include a timezone offset")
        return value

    @field_validator("symptoms")
    @classmethod
    def clean_symptoms(cls, values: list[str]) -> list[str]:
        cleaned = [value.strip() for value in values if value.strip()]
        if any(len(value) > 80 for value in cleaned):
            raise ValueError("each symptom must be 80 characters or fewer")
        return list(dict.fromkeys(cleaned))


class FeverEntryUpdate(BaseModel):
    temperature_c: float | None = Field(default=None, ge=30, le=45)
    measured_at: datetime | None = None
    measurement_method: MeasurementMethod | None = None
    symptoms: list[str] | None = Field(default=None, max_length=20)
    notes: str | None = Field(default=None, max_length=1000)
    medicine_taken: bool | None = None

    @field_validator("measured_at")
    @classmethod
    def require_timezone(cls, value: datetime | None) -> datetime | None:
        if value is not None and (value.tzinfo is None or value.utcoffset() is None):
            raise ValueError("measured_at must include a timezone offset")
        return value

    @field_validator("symptoms")
    @classmethod
    def clean_symptoms(cls, values: list[str] | None) -> list[str] | None:
        if values is None:
            return None
        cleaned = [value.strip() for value in values if value.strip()]
        if any(len(value) > 80 for value in cleaned):
            raise ValueError("each symptom must be 80 characters or fewer")
        return list(dict.fromkeys(cleaned))


class FeverEntryRead(FeverEntryCreate):
    model_config = ConfigDict(from_attributes=True)

    id: UUID
    created_at: datetime
    updated_at: datetime

