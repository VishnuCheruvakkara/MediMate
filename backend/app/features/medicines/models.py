from datetime import datetime, time, timezone
from uuid import UUID, uuid4

from sqlalchemy import Boolean, DateTime, ForeignKey, Integer, String, Time
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.core.database import Base


def utc_now() -> datetime:
    return datetime.now(timezone.utc)


class Medicine(Base):
    __tablename__ = "medicines"

    id: Mapped[UUID] = mapped_column(primary_key=True, default=uuid4)
    name: Mapped[str] = mapped_column(String(120), index=True)
    dosage: Mapped[str] = mapped_column(String(80))
    instructions: Mapped[str | None] = mapped_column(String(500), nullable=True)
    food_timing: Mapped[str] = mapped_column(String(30), default="as_directed")
    dose_pattern: Mapped[str | None] = mapped_column(String(40), nullable=True)
    schedule_mode: Mapped[str] = mapped_column(String(20), default="fixed_times")
    interval_hours: Mapped[int | None] = mapped_column(Integer, nullable=True)
    interval_start_time: Mapped[time | None] = mapped_column(Time(), nullable=True)
    is_active: Mapped[bool] = mapped_column(Boolean, default=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utc_now)
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), default=utc_now, onupdate=utc_now
    )

    schedules: Mapped[list["DoseSchedule"]] = relationship(
        back_populates="medicine",
        cascade="all, delete-orphan",
        lazy="selectin",
    )


class DoseSchedule(Base):
    __tablename__ = "dose_schedules"

    id: Mapped[UUID] = mapped_column(primary_key=True, default=uuid4)
    medicine_id: Mapped[UUID] = mapped_column(
        ForeignKey("medicines.id", ondelete="CASCADE"), index=True
    )
    time_of_day: Mapped[time] = mapped_column(Time())
    interval_days: Mapped[int] = mapped_column(Integer, default=1)

    medicine: Mapped[Medicine] = relationship(back_populates="schedules")

