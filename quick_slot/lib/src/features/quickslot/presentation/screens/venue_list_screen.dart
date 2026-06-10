import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quick_slot/src/config/app_config.dart';
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
        title: const Text('Sports'),
        actions: [
          IconButton(
            onPressed: () => context.push(AppRoutes.bookings),
            icon: const Icon(Icons.event_available_rounded),
            tooltip: 'My Bookings',
          ),
        ],
      ),
      body: SafeArea(
        child: venuesState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => AppErrorWidget(
            title: 'Backend not reachable',
            message: '${error.toString()}\n\nCurrent API: ${AppConfig.baseUrl}',
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
                  _Header(userName: user?.name ?? 'guest'),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text(
                        'Nearby venues',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const Spacer(),
                      Text(
                        '${venues.length} open',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  for (final venue in venues)
                    _VenueCard(
                      venue: venue,
                      onTap: () =>
                          context.push('${AppRoutes.venues}/${venue.id}'),
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

class _Header extends StatelessWidget {
  const _Header({required this.userName});

  final String userName;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.primary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Book your next game',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Logged in as $userName',
                  style: TextStyle(
                    color: colorScheme.onPrimary.withValues(alpha: 0.82),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: colorScheme.onPrimary.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(8),
            ),
            child:
                Icon(Icons.sports_tennis_rounded, color: colorScheme.onPrimary),
          ),
        ],
      ),
    );
  }
}

class _VenueCard extends StatelessWidget {
  const _VenueCard({required this.venue, required this.onTap});

  final Venue venue;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _VenueVisual(venue: venue),
            Padding(
              padding: const EdgeInsets.all(14),
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
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star_rounded,
                              size: 16,
                              color: colorScheme.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              venue.rating,
                              style: TextStyle(
                                color: colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _MetaChip(label: venue.sport),
                      _MetaChip(label: 'Rs ${venue.pricePerHour}/hr'),
                      const _MetaChip(label: '6 AM - 10 PM'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 18,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          venue.location,
                          style: TextStyle(color: colorScheme.onSurfaceVariant),
                        ),
                      ),
                      Icon(Icons.chevron_right_rounded,
                          color: colorScheme.primary),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VenueVisual extends StatelessWidget {
  const _VenueVisual({required this.venue});

  final Venue venue;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final icon = switch (venue.sport) {
      'Badminton' => Icons.sports_tennis_rounded,
      'Football Turf' => Icons.sports_soccer_rounded,
      'Cricket Turf' => Icons.sports_cricket_rounded,
      _ => Icons.sports_rounded,
    };

    return AspectRatio(
      aspectRatio: 16 / 7,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colorScheme.primary,
              const Color(0xFF10B981),
            ],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -20,
              top: -18,
              child: Icon(
                icon,
                size: 132,
                color: Colors.white.withValues(alpha: 0.16),
              ),
            ),
            Positioned(
              left: 14,
              bottom: 14,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.28),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Available today',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}
