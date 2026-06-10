import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quick_slot/src/features/quickslot/data/quickslot_api.dart';
import 'package:quick_slot/src/features/quickslot/data/quickslot_models.dart';
import 'package:quick_slot/src/features/quickslot/presentation/providers/quickslot_providers.dart';
import 'package:quick_slot/src/shared/widgets/app_empty_state.dart';
import 'package:quick_slot/src/shared/widgets/app_error_widget.dart';

class VenueDetailScreen extends ConsumerStatefulWidget {
  const VenueDetailScreen({super.key, required this.venueId});

  final int venueId;

  @override
  ConsumerState<VenueDetailScreen> createState() => _VenueDetailScreenState();
}

class _VenueDetailScreenState extends ConsumerState<VenueDetailScreen> {
  int? _bookingSlotId;

  @override
  Widget build(BuildContext context) {
    final venuesState = ref.watch(venuesProvider);
    final slotsState = ref.watch(slotsProvider(widget.venueId));
    final date = ref.watch(selectedDateProvider);

    Venue? venue;
    for (final item in venuesState.valueOrNull ?? <Venue>[]) {
      if (item.id == widget.venueId) {
        venue = item;
        break;
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text(venue?.name ?? 'Venue')),
      body: SafeArea(
        child: Column(
          children: [
            _DateStrip(selectedDate: date),
            Expanded(
              child: slotsState.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => AppErrorWidget(
                  message: error.toString(),
                  onRetry: () => ref.invalidate(slotsProvider(widget.venueId)),
                ),
                data: (slots) {
                  if (slots.isEmpty) {
                    return const AppEmptyState(
                      title: 'No slots for this date',
                      subtitle: 'Try another date.',
                    );
                  }
                  return GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 2.6,
                    ),
                    itemCount: slots.length,
                    itemBuilder: (context, index) {
                      final slot = slots[index];
                      return _SlotTile(
                        slot: slot,
                        isLoading: _bookingSlotId == slot.id,
                        onTap: slot.isAvailable ? () => _confirmBooking(slot) : null,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmBooking(Slot slot) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm booking'),
        content: Text('Book ${_hour(slot.startHour)} - ${_hour(slot.endHour)}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Book')),
        ],
      ),
    );
    if (confirmed != true) {
      return;
    }

    final user = ref.read(selectedUserProvider);
    if (user == null) {
      _showMessage('Select a user before booking.');
      return;
    }

    setState(() => _bookingSlotId = slot.id);
    try {
      await quickSlotApi.createBooking(slot: slot, user: user);
      ref.invalidate(slotsProvider(widget.venueId));
      ref.invalidate(bookingsProvider);
      if (mounted) {
        _showMessage('Booked successfully.');
      }
    } on SlotTakenException catch (error) {
      ref.invalidate(slotsProvider(widget.venueId));
      if (mounted) {
        _showMessage(error.message);
      }
    } on DioException catch (error) {
      if (mounted) {
        _showMessage(error.response?.data.toString() ?? error.message ?? 'Booking failed.');
      }
    } finally {
      if (mounted) {
        setState(() => _bookingSlotId = null);
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  String _hour(int hour) {
    final suffix = hour >= 12 ? 'PM' : 'AM';
    final display = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return '$display $suffix';
  }
}

class _DateStrip extends ConsumerWidget {
  const _DateStrip({required this.selectedDate});

  final DateTime selectedDate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = DateTime.now();
    final dates = List.generate(7, (index) {
      final raw = today.add(Duration(days: index));
      return DateTime(raw.year, raw.month, raw.day);
    });

    return SizedBox(
      height: 88,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        scrollDirection: Axis.horizontal,
        itemCount: dates.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final date = dates[index];
          final selected = _sameDay(date, selectedDate);
          return ChoiceChip(
            selected: selected,
            label: SizedBox(
              width: 64,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(index == 0 ? 'Today' : '${date.day}/${date.month}'),
                  Text(_weekday(date), style: Theme.of(context).textTheme.labelSmall),
                ],
              ),
            ),
            onSelected: (_) => ref.read(selectedDateProvider.notifier).state = date,
          );
        },
      ),
    );
  }

  bool _sameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _weekday(DateTime date) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[date.weekday - 1];
  }
}

class _SlotTile extends StatelessWidget {
  const _SlotTile({required this.slot, required this.isLoading, this.onTap});

  final Slot slot;
  final bool isLoading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final available = slot.isAvailable;
    final background = available ? colorScheme.primaryContainer : colorScheme.surfaceContainerHighest;
    final foreground = available ? colorScheme.onPrimaryContainer : colorScheme.onSurfaceVariant;

    return Material(
      color: background,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: isLoading ? null : onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Icon(available ? Icons.check_circle_rounded : Icons.lock_rounded, color: foreground),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${_hour(slot.startHour)} - ${_hour(slot.endHour)}',
                  style: TextStyle(color: foreground, fontWeight: FontWeight.w700),
                ),
              ),
              if (isLoading)
                SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: foreground),
                ),
            ],
          ),
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
