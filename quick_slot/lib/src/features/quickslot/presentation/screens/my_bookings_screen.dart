import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quick_slot/src/features/quickslot/data/quickslot_api.dart';
import 'package:quick_slot/src/features/quickslot/data/quickslot_models.dart';
import 'package:quick_slot/src/features/quickslot/presentation/providers/quickslot_providers.dart';
import 'package:quick_slot/src/shared/widgets/app_empty_state.dart';
import 'package:quick_slot/src/shared/widgets/app_error_widget.dart';

class MyBookingsScreen extends ConsumerStatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  ConsumerState<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends ConsumerState<MyBookingsScreen> {
  int? _cancellingId;

  @override
  Widget build(BuildContext context) {
    final bookingsState =
        ref.watch<AsyncValue<List<Booking>>>(bookingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Bookings')),
      body: SafeArea(
        child: bookingsState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => AppErrorWidget(
            message: error.toString(),
            onRetry: () => ref.invalidate(bookingsProvider),
          ),
          data: (bookings) {
            if (bookings.isEmpty) {
              return const AppEmptyState(
                title: 'No bookings yet',
                subtitle: 'Your confirmed slots will appear here.',
              );
            }
            return RefreshIndicator(
              onRefresh: () async => ref.invalidate(bookingsProvider),
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: bookings.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final booking = bookings[index];
                  return Card(
                    margin: EdgeInsets.zero,
                    child: ListTile(
                      title: Text(booking.venueName),
                      subtitle: Text(
                        '${booking.sport} • ${booking.location}\n'
                        '${booking.date.day}/${booking.date.month}/${booking.date.year} • '
                        '${_hour(booking.startHour)} - ${_hour(booking.endHour)}',
                      ),
                      isThreeLine: true,
                      trailing: _cancellingId == booking.id
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : IconButton(
                              icon: const Icon(Icons.delete_outline_rounded),
                              onPressed: () => _cancel(booking),
                            ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _cancel(Booking booking) async {
    final user = ref.read<QuickUser?>(selectedUserProvider);
    if (user == null) {
      return;
    }
    setState(() => _cancellingId = booking.id);
    try {
      await quickSlotApi.cancelBooking(bookingId: booking.id, user: user);
      ref.invalidate(bookingsProvider);
      ref.invalidate(slotsProvider(booking.venueId));
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Booking cancelled.')));
      }
    } finally {
      if (mounted) {
        setState(() => _cancellingId = null);
      }
    }
  }

  String _hour(int hour) {
    final suffix = hour >= 12 ? 'PM' : 'AM';
    final display = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return '$display $suffix';
  }
}
