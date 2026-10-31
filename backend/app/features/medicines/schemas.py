from datetime import datetime, time
from enum import StrEnum
from uuid import UUID

from pydantic import BaseModel, ConfigDict, Field, field_validator, model_validator


class FoodTiming(StrEnum):
    BEFORE_FOOD = "before_food"
    AFTER_FOOD = "after_food"
    WITH_FOOD = "with_food"
    EMPTY_STOMACH = "empty_stomach"
    ANYTIME = "anytime"
    AS_DIRECTED = "as_directed"


class ScheduleMode(StrEnum):
    FIXED_TIMES = "fixed_times"
    INTERVAL = "interval"


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
    food_timing: FoodTiming = FoodTiming.AS_DIRECTED
    dose_pattern: str | None = Field(default=None, max_length=40)
    schedule_mode: ScheduleMode = ScheduleMode.FIXED_TIMES
    interval_hours: int | None = Field(default=None, ge=1, le=24)
    interval_start_time: time | None = None
    schedules: list[ScheduleCreate] = Field(default_factory=list, max_length=24)

    @field_validator("dose_pattern")
    @classmethod
    def validate_dose_pattern(cls, value: str | None) -> str | None:
        if value is None or not value.strip():
            return None
        parts = value.strip().split("-")
        if not 1 <= len(parts) <= 4:
            raise ValueError("dose pattern must contain one to four dose periods")
        try:
            doses = [float(part) for part in parts]
        except ValueError as error:
            raise ValueError("dose pattern must use numbers separated by hyphens") from error
        if any(dose < 0 or dose > 10 for dose in doses):
            raise ValueError("each dose in the pattern must be between 0 and 10")
        return "-".join(parts)

    @model_validator(mode="after")
    def validate_schedule(self):
        if self.schedule_mode == ScheduleMode.FIXED_TIMES and not self.schedules:
            raise ValueError("fixed-time schedules require at least one dose time")
        if self.schedule_mode == ScheduleMode.INTERVAL:
            if self.interval_hours is None or self.interval_start_time is None:
                raise ValueError("interval schedules require a gap and start time")
        return self


class MedicineUpdate(BaseModel):
    name: str | None = Field(default=None, min_length=1, max_length=120)
    dosage: str | None = Field(default=None, min_length=1, max_length=80)
    instructions: str | None = Field(default=None, max_length=500)
    food_timing: FoodTiming | None = None
    dose_pattern: str | None = Field(default=None, max_length=40)
    schedule_mode: ScheduleMode | None = None
    interval_hours: int | None = Field(default=None, ge=1, le=24)
    interval_start_time: time | None = None
    is_active: bool | None = None
    schedules: list[ScheduleCreate] | None = Field(default=None, max_length=24)


class MedicineRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: UUID
    name: str
    dosage: str
    instructions: str | None
    food_timing: FoodTiming
    dose_pattern: str | None
    schedule_mode: ScheduleMode
    interval_hours: int | None
    interval_start_time: time | None
    is_active: bool
    schedules: list[ScheduleRead]
    created_at: datetime
    updated_at: datetime

