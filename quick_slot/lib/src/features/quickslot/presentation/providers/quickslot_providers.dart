import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quick_slot/src/features/quickslot/data/quickslot_api.dart';
import 'package:quick_slot/src/features/quickslot/data/quickslot_models.dart';

const demoUsers = [
  QuickUser(id: 'u1', name: 'Aarav'),
  QuickUser(id: 'u2', name: 'Biswajit'),
  QuickUser(id: 'u3', name: 'Maya'),
];

final selectedUserProvider = StateProvider<QuickUser?>((ref) => null);

final selectedDateProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
});

final venuesProvider = FutureProvider<List<Venue>>((ref) {
  return quickSlotApi.getVenues();
});

final slotsProvider = FutureProvider.family<List<Slot>, int>((ref, venueId) {
  final date = ref.watch(selectedDateProvider);
  return quickSlotApi.getSlots(venueId: venueId, date: date);
});

final bookingsProvider = FutureProvider<List<Booking>>((ref) {
  final user = ref.watch(selectedUserProvider);
  if (user == null) {
    return const [];
  }
  return quickSlotApi.getUserBookings(user.id);
});
