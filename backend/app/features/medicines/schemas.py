from datetime import datetime, time
from uuid import UUID

from pydantic import BaseModel, ConfigDict, Field


class ScheduleCreate(BaseModel):
    time_of_day: time
    interval_days: int = Field(default=1, ge=1, le=365)


class ScheduleRead(ScheduleCreate):
    model_config = ConfigDict(from_attributes=True)

    id: UUID


class MedicineCreate(BaseModel):
    name: str = Field(min_length=1, max_length=120)
    dosage: str = Field(min_length=1, max_length=80)
    instructions: str | None = Field(default=None, max_length=500)
    schedules: list[ScheduleCreate] = Field(default_factory=list, max_length=24)


class MedicineUpdate(BaseModel):
    name: str | None = Field(default=None, min_length=1, max_length=120)
    dosage: str | None = Field(default=None, min_length=1, max_length=80)
    instructions: str | None = Field(default=None, max_length=500)
    is_active: bool | None = None
    schedules: list[ScheduleCreate] | None = Field(default=None, max_length=24)


class MedicineRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: UUID
    name: str
    dosage: str
    instructions: str | None
    is_active: bool
    schedules: list[ScheduleRead]
    created_at: datetime
    updated_at: datetime

