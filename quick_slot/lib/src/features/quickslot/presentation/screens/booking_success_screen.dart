import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:quick_slot/src/features/quickslot/data/quickslot_models.dart';
import 'package:quick_slot/src/routing/app_routes.dart';

class BookingSuccessScreen extends StatelessWidget {
  const BookingSuccessScreen({super.key, required this.booking});

  final Booking? booking;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Booking Confirmed')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 92,
                height: 92,
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981),
                  borderRadius: BorderRadius.circular(46),
                ),
                child: const Icon(Icons.check_rounded,
                    color: Colors.white, size: 54),
              ),
              const SizedBox(height: 24),
              Text(
                'Booking Confirmed',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your slot is locked. If another user tries the same slot now, the backend returns 409 Conflict.',
                textAlign: TextAlign.center,
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 24),
              if (booking != null) _SuccessCard(booking: booking!),
              const Spacer(),
              FilledButton.icon(
                onPressed: () => context.go(AppRoutes.bookings),
                icon: const Icon(Icons.event_available_rounded),
                label: const Text('View My Bookings'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(54),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: () => context.go(AppRoutes.venues),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(54),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Back to Venues'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SuccessCard extends StatelessWidget {
  const _SuccessCard({required this.booking});

  final Booking booking;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              booking.venueName,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
            const SizedBox(height: 8),
            _Row(icon: Icons.sports_tennis_rounded, text: booking.sport),
            _Row(icon: Icons.location_on_outlined, text: booking.location),
            _Row(
              icon: Icons.calendar_today_rounded,
              text:
                  '${booking.date.day}/${booking.date.month}/${booking.date.year}',
            ),
            _Row(
              icon: Icons.schedule_rounded,
              text: '${_hour(booking.startHour)} - ${_hour(booking.endHour)}',
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Booking ID: QS-${booking.id.toString().padLeft(5, '0')}',
                style: TextStyle(
                  color: colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _hour(int hour) {
    final suffix = hour >= 12 ? 'PM' : 'AM';
    final display = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return '$display $suffix';
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
