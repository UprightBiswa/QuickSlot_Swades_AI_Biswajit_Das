import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quick_slot/src/features/quickslot/data/quickslot_api.dart';
import 'package:quick_slot/src/features/quickslot/data/quickslot_models.dart';
import 'package:quick_slot/src/features/quickslot/presentation/providers/quickslot_providers.dart';
import 'package:quick_slot/src/features/quickslot/presentation/widgets/quickslot_bottom_nav.dart';
import 'package:quick_slot/src/routing/app_routes.dart';
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
      bottomNavigationBar: const QuickSlotBottomNav(currentIndex: 1),
      body: SafeArea(
        child: bookingsState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => AppErrorWidget(
            message: error.toString(),
            onRetry: () => ref.invalidate(bookingsProvider),
          ),
          data: (bookings) {
            if (bookings.isEmpty) {
              return AppEmptyState(
                title: 'No bookings yet',
                subtitle: 'Your confirmed slots will appear here.',
                actionLabel: 'Find a venue',
                onAction: () => context.go(AppRoutes.venues),
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
                  return _BookingCard(
                    booking: booking,
                    isCancelling: _cancellingId == booking.id,
                    onCancel: () => _confirmCancel(booking),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _confirmCancel(Booking booking) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel booking?'),
        content: Text(
          'Cancel ${booking.venueName} at ${_hour(booking.startHour)}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Cancel booking'),
          ),
        ],
      ),
    );
    if (confirmed ?? false) {
      await _cancel(booking);
    }
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
    } on QuickSlotApiException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.message)));
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

class _BookingCard extends StatelessWidget {
  const _BookingCard({
    required this.booking,
    required this.isCancelling,
    required this.onCancel,
  });

  final Booking booking;
  final bool isCancelling;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            height: 92,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [colorScheme.primary, const Color(0xFF10B981)],
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -10,
                  top: -18,
                  child: Icon(
                    Icons.event_available_rounded,
                    size: 118,
                    color: Colors.white.withValues(alpha: 0.18),
                  ),
                ),
                Positioned(
                  left: 14,
                  bottom: 14,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Confirmed',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking.venueName,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 8),
                Text('${booking.sport} - ${booking.location}'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 18,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${booking.date.day}/${booking.date.month}/${booking.date.year}',
                    ),
                    const Spacer(),
                    Icon(
                      Icons.schedule_rounded,
                      size: 18,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${_hour(booking.startHour)} - ${_hour(booking.endHour)}',
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Text(
                      'QS-${booking.id.toString().padLeft(5, '0')}',
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    if (isCancelling)
                      const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    else
                      TextButton.icon(
                        onPressed: onCancel,
                        icon: const Icon(Icons.delete_outline_rounded),
                        label: const Text('Cancel'),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _hour(int hour) {
    final suffix = hour >= 12 ? 'PM' : 'AM';
    final display = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return '$display $suffix';
  }
}
