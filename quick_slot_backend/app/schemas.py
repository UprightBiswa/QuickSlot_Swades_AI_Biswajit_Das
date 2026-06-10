from datetime import date, datetime

from pydantic import BaseModel, Field


class VenueOut(BaseModel):
    id: int
    name: str
    sport: str
    location: str
    price_per_hour: int
    rating: str

    model_config = {"from_attributes": True}


class SlotOut(BaseModel):
    id: int
    venue_id: int
    date: date
    start_hour: int
    end_hour: int
    status: str
    booked_by_user_id: str | None = None


class BookingCreate(BaseModel):
    slot_id: int = Field(gt=0)
    user_name: str = Field(min_length=2, max_length=120)


class BookingOut(BaseModel):
    id: int
    user_id: str
    user_name: str
    slot_id: int
    venue_id: int
    venue_name: str
    sport: str
    location: str
    date: date
    start_hour: int
    end_hour: int
    created_at: datetime


class ErrorOut(BaseModel):
    detail: str
