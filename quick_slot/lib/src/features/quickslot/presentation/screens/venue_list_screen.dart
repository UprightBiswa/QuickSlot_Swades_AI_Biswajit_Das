import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quick_slot/src/features/quickslot/data/quickslot_models.dart';
import 'package:quick_slot/src/features/quickslot/presentation/providers/quickslot_providers.dart';
import 'package:quick_slot/src/routing/app_routes.dart';
import 'package:quick_slot/src/shared/widgets/app_empty_state.dart';
import 'package:quick_slot/src/shared/widgets/app_error_widget.dart';

class VenueListScreen extends ConsumerWidget {
  const VenueListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final venuesState = ref.watch<AsyncValue<List<Venue>>>(venuesProvider);
    final user = ref.watch<QuickUser?>(selectedUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('QuickSlot'),
        actions: [
          TextButton.icon(
            onPressed: () => context.push(AppRoutes.bookings),
            icon: const Icon(Icons.event_available_rounded),
            label: const Text('My Bookings'),
          ),
        ],
      ),
      body: SafeArea(
        child: venuesState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => AppErrorWidget(
            message: error.toString(),
            onRetry: () => ref.invalidate(venuesProvider),
          ),
          data: (venues) {
            if (venues.isEmpty) {
              return AppEmptyState(
                title: 'No venues yet',
                subtitle:
                    'Seed data did not load. Restart the backend and try again.',
                onAction: () => ref.invalidate(venuesProvider),
                actionLabel: 'Refresh',
              );
            }
            return RefreshIndicator(
              onRefresh: () async => ref.invalidate(venuesProvider),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      'Booking as ${user?.name ?? 'guest'}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  for (final venue in venues)
                    Card(
                      margin: const EdgeInsets.only(bottom: 14),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () =>
                            context.push('${AppRoutes.venues}/${venue.id}'),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      venue.name,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.copyWith(
                                              fontWeight: FontWeight.w800),
                                    ),
                                  ),
                                  Chip(
                                    avatar: const Icon(Icons.star_rounded,
                                        size: 16),
                                    label: Text(venue.rating),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  Chip(label: Text(venue.sport)),
                                  Chip(
                                      label:
                                          Text('Rs ${venue.pricePerHour}/hr')),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  const Icon(Icons.location_on_outlined,
                                      size: 18),
                                  const SizedBox(width: 6),
                                  Expanded(child: Text(venue.location)),
                                  const Icon(Icons.chevron_right_rounded),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
