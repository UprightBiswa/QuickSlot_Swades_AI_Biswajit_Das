import logging
import os
from contextlib import asynccontextmanager
from datetime import date

from fastapi import Depends, FastAPI, Header, HTTPException, Query, Response, status
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session, joinedload

from app.database import Base, SessionLocal, engine, get_db
from app.models import Booking, Slot, Venue
from app.schemas import BookingCreate, BookingOut, SlotOut, VenueOut
from app.seed import ensure_slots_for_date, seed_data

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("quickslot")

@asynccontextmanager
async def lifespan(app: FastAPI):
    Base.metadata.create_all(bind=engine)
    with SessionLocal() as db:
        seed_data(db)
    logger.info("QuickSlot API started")
    yield


app = FastAPI(title="QuickSlot API", version="1.0.0", lifespan=lifespan)

origins = [origin.strip() for origin in os.getenv("ALLOWED_ORIGINS", "*").split(",")]
app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/health")
def health() -> dict[str, str]:
    return {"status": "ok"}


@app.get("/venues", response_model=list[VenueOut])
def list_venues(db: Session = Depends(get_db)) -> list[Venue]:
    return db.query(Venue).order_by(Venue.name).all()


@app.get("/venues/{venue_id}/slots", response_model=list[SlotOut])
def list_slots(
    venue_id: int,
    date_: date = Query(alias="date"),
    db: Session = Depends(get_db),
) -> list[SlotOut]:
    venue = db.get(Venue, venue_id)
    if venue is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Venue not found")

    ensure_slots_for_date(db, date_)
    slots = (
        db.query(Slot)
        .options(joinedload(Slot.booking))
        .filter(Slot.venue_id == venue_id, Slot.date == date_)
        .order_by(Slot.start_hour)
        .all()
    )
    return [
        SlotOut(
            id=slot.id,
            venue_id=slot.venue_id,
            date=slot.date,
            start_hour=slot.start_hour,
            end_hour=slot.end_hour,
            status="booked" if slot.booking else "available",
            booked_by_user_id=slot.booking.user_id if slot.booking else None,
        )
        for slot in slots
    ]


@app.post(
    "/bookings",
    response_model=BookingOut,
    status_code=status.HTTP_201_CREATED,
    responses={409: {"description": "Slot already taken"}, 422: {"description": "Invalid input"}},
)
def create_booking(
    payload: BookingCreate,
    x_user_id: str = Header(min_length=1),
    db: Session = Depends(get_db),
) -> BookingOut:
    slot = db.query(Slot).options(joinedload(Slot.venue)).filter(Slot.id == payload.slot_id).first()
    if slot is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Slot not found")

    booking = Booking(slot_id=payload.slot_id, user_id=x_user_id, user_name=payload.user_name)
    db.add(booking)
    try:
        db.commit()
    except IntegrityError:
        db.rollback()
        logger.info("Double booking blocked for slot_id=%s user_id=%s", payload.slot_id, x_user_id)
        raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail="Sorry, this slot was just booked.")

    db.refresh(booking)
    return _booking_out(booking, slot)


@app.get("/users/{user_id}/bookings", response_model=list[BookingOut])
def user_bookings(user_id: str, db: Session = Depends(get_db)) -> list[BookingOut]:
    bookings = (
        db.query(Booking)
        .options(joinedload(Booking.slot).joinedload(Slot.venue))
        .filter(Booking.user_id == user_id)
        .order_by(Booking.created_at.desc())
        .all()
    )
    return [_booking_out(booking, booking.slot) for booking in bookings]


@app.delete("/bookings/{booking_id}", status_code=status.HTTP_204_NO_CONTENT)
def cancel_booking(
    booking_id: int,
    x_user_id: str = Header(min_length=1),
    db: Session = Depends(get_db),
) -> Response:
    booking = db.get(Booking, booking_id)
    if booking is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Booking not found")
    if booking.user_id != x_user_id:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="You can only cancel your own booking")

    db.delete(booking)
    db.commit()
    return Response(status_code=status.HTTP_204_NO_CONTENT)


def _booking_out(booking: Booking, slot: Slot) -> BookingOut:
    venue = slot.venue
    return BookingOut(
        id=booking.id,
        user_id=booking.user_id,
        user_name=booking.user_name,
        slot_id=slot.id,
        venue_id=venue.id,
        venue_name=venue.name,
        sport=venue.sport,
        location=venue.location,
        date=slot.date,
        start_hour=slot.start_hour,
        end_hour=slot.end_hour,
        created_at=booking.created_at,
    )
