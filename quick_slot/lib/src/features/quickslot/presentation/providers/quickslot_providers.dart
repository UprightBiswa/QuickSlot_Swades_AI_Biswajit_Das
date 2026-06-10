import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:quick_slot/src/features/quickslot/data/quickslot_api.dart';
import 'package:quick_slot/src/features/quickslot/data/quickslot_models.dart';

const demoUsers = [
  QuickUser(id: 'u1', name: 'Aarav'),
  QuickUser(id: 'u2', name: 'Biswajit'),
  QuickUser(id: 'u3', name: 'Maya'),
];

final selectedUserProvider = StateProvider<QuickUser?>((ref) => null);

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

final venueSearchProvider = StateProvider<String>((ref) => '');

final selectedDateProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
});

final venuesProvider = FutureProvider<List<Venue>>((ref) {
  return quickSlotApi.getVenues();
});

final filteredVenuesProvider = FutureProvider<List<Venue>>((ref) async {
  final query = ref.watch<String>(venueSearchProvider).trim().toLowerCase();
  final venues = await ref.watch(venuesProvider.future);
  if (query.isEmpty) {
    return venues;
  }
  return venues.where((venue) {
    return venue.name.toLowerCase().contains(query) ||
        venue.sport.toLowerCase().contains(query) ||
        venue.location.toLowerCase().contains(query);
  }).toList();
});

final slotsProvider = FutureProvider.family<List<Slot>, int>((ref, venueId) {
  final date = ref.watch<DateTime>(selectedDateProvider);
  return quickSlotApi.getSlots(venueId: venueId, date: date);
});

final bookingsProvider = FutureProvider<List<Booking>>((ref) {
  final user = ref.watch<QuickUser?>(selectedUserProvider);
  if (user == null) {
    return const [];
  }
  return quickSlotApi.getUserBookings(user.id);
});
