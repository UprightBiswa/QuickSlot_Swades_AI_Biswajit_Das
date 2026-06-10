class QuickUser {
  const QuickUser({required this.id, required this.name});

  final String id;
  final String name;
}

class Venue {
  const Venue({
    required this.id,
    required this.name,
    required this.sport,
    required this.location,
    required this.pricePerHour,
    required this.rating,
  });

  factory Venue.fromJson(Map<String, dynamic> json) {
    return Venue(
      id: json['id'] as int,
      name: json['name'] as String,
      sport: json['sport'] as String,
      location: json['location'] as String,
      pricePerHour: json['price_per_hour'] as int,
      rating: json['rating'] as String,
    );
  }

  final int id;
  final String name;
  final String sport;
  final String location;
  final int pricePerHour;
  final String rating;
}

class Slot {
  const Slot({
    required this.id,
    required this.venueId,
    required this.date,
    required this.startHour,
    required this.endHour,
    required this.status,
    this.bookedByUserId,
  });

  factory Slot.fromJson(Map<String, dynamic> json) {
    return Slot(
      id: json['id'] as int,
      venueId: json['venue_id'] as int,
      date: DateTime.parse(json['date'] as String),
      startHour: json['start_hour'] as int,
      endHour: json['end_hour'] as int,
      status: json['status'] as String,
      bookedByUserId: json['booked_by_user_id'] as String?,
    );
  }

  final int id;
  final int venueId;
  final DateTime date;
  final int startHour;
  final int endHour;
  final String status;
  final String? bookedByUserId;

  bool get isAvailable => status == 'available';
}

class Booking {
  const Booking({
    required this.id,
    required this.userId,
    required this.userName,
    required this.slotId,
    required this.venueId,
    required this.venueName,
    required this.sport,
    required this.location,
    required this.date,
    required this.startHour,
    required this.endHour,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] as int,
      userId: json['user_id'] as String,
      userName: json['user_name'] as String,
      slotId: json['slot_id'] as int,
      venueId: json['venue_id'] as int,
      venueName: json['venue_name'] as String,
      sport: json['sport'] as String,
      location: json['location'] as String,
      date: DateTime.parse(json['date'] as String),
      startHour: json['start_hour'] as int,
      endHour: json['end_hour'] as int,
    );
  }

  final int id;
  final String userId;
  final String userName;
  final int slotId;
  final int venueId;
  final String venueName;
  final String sport;
  final String location;
  final DateTime date;
  final int startHour;
  final int endHour;
}
