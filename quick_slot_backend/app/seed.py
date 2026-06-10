from datetime import date, timedelta

from sqlalchemy.orm import Session

from app.models import Slot, Venue


VENUES = [
    {"name": "Smash Arena", "sport": "Badminton", "location": "Salt Lake Sector V", "price_per_hour": 650, "rating": "4.8"},
    {"name": "Turf Ninety", "sport": "Football Turf", "location": "New Town Action Area I", "price_per_hour": 1600, "rating": "4.6"},
    {"name": "Ace Courts", "sport": "Tennis", "location": "Ballygunge", "price_per_hour": 900, "rating": "4.7"},
    {"name": "PowerPlay Box", "sport": "Cricket Turf", "location": "Rajarhat", "price_per_hour": 1400, "rating": "4.5"},
]


def seed_data(db: Session) -> None:
    if db.query(Venue).count() == 0:
        db.add_all(Venue(**venue) for venue in VENUES)
        db.commit()

    today = date.today()
    for offset in range(14):
        ensure_slots_for_date(db, today + timedelta(days=offset))


def ensure_slots_for_date(db: Session, slot_date: date) -> None:
    venues = db.query(Venue).all()
    for venue in venues:
        existing_hours = {
            row[0]
            for row in db.query(Slot.start_hour)
            .filter(Slot.venue_id == venue.id, Slot.date == slot_date)
            .all()
        }
        for hour in range(6, 22):
            if hour not in existing_hours:
                db.add(Slot(venue_id=venue.id, date=slot_date, start_hour=hour, end_hour=hour + 1))
    db.commit()
