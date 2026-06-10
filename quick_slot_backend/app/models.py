from sqlalchemy import Date, DateTime, ForeignKey, Integer, String, UniqueConstraint, func
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.database import Base


class Venue(Base):
    __tablename__ = "venues"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    name: Mapped[str] = mapped_column(String(120), nullable=False)
    sport: Mapped[str] = mapped_column(String(40), nullable=False)
    location: Mapped[str] = mapped_column(String(160), nullable=False)
    price_per_hour: Mapped[int] = mapped_column(Integer, nullable=False)
    rating: Mapped[str] = mapped_column(String(8), nullable=False, default="4.6")

    slots: Mapped[list["Slot"]] = relationship(back_populates="venue")


class Slot(Base):
    __tablename__ = "slots"
    __table_args__ = (UniqueConstraint("venue_id", "date", "start_hour", name="uq_slot_time"),)

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    venue_id: Mapped[int] = mapped_column(ForeignKey("venues.id"), nullable=False, index=True)
    date: Mapped[Date] = mapped_column(Date, nullable=False, index=True)
    start_hour: Mapped[int] = mapped_column(Integer, nullable=False)
    end_hour: Mapped[int] = mapped_column(Integer, nullable=False)

    venue: Mapped[Venue] = relationship(back_populates="slots")
    booking: Mapped["Booking | None"] = relationship(back_populates="slot", uselist=False)


class Booking(Base):
    __tablename__ = "bookings"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    slot_id: Mapped[int] = mapped_column(ForeignKey("slots.id"), nullable=False, unique=True, index=True)
    user_id: Mapped[str] = mapped_column(String(40), nullable=False, index=True)
    user_name: Mapped[str] = mapped_column(String(120), nullable=False)
    created_at: Mapped[DateTime] = mapped_column(DateTime(timezone=True), server_default=func.now())

    slot: Mapped[Slot] = relationship(back_populates="booking")
