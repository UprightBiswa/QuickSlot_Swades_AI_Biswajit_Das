import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';
import 'package:quick_slot/src/config/app_config.dart';
import 'package:quick_slot/src/features/quickslot/data/quickslot_models.dart';
import 'package:quick_slot/src/features/quickslot/presentation/providers/quickslot_providers.dart';
import 'package:quick_slot/src/features/quickslot/presentation/widgets/quickslot_bottom_nav.dart';
import 'package:quick_slot/src/routing/app_routes.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch<QuickUser?>(selectedUserProvider);
    final themeMode = ref.watch<ThemeMode>(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      bottomNavigationBar: const QuickSlotBottomNav(currentIndex: 2),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 34,
                      backgroundColor: colorScheme.primary,
                      child: Text(
                        (user?.name ?? 'G').characters.first,
                        style: TextStyle(
                          color: colorScheme.onPrimary,
                          fontWeight: FontWeight.w900,
                          fontSize: 24,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.name ?? 'Guest',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Demo user - ${user?.id ?? 'not selected'}',
                            style:
                                TextStyle(color: colorScheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    value: isDark,
                    onChanged: (value) {
                      ref
                          .read<StateController<ThemeMode>>(
                            themeModeProvider.notifier,
                          )
                          .state = value ? ThemeMode.dark : ThemeMode.light;
                    },
                    secondary: const Icon(Icons.dark_mode_outlined),
                    title: const Text('Dark theme'),
                    subtitle: const Text('Useful for indoor demo lighting'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.link_rounded),
                    title: const Text('API endpoint'),
                    subtitle: Text(AppConfig.baseUrl),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.swap_horiz_rounded),
                    title: const Text('Change user'),
                    subtitle: const Text('Return to demo login list'),
                    onTap: () => context.go(AppRoutes.userSelect),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading:
                        Icon(Icons.logout_rounded, color: colorScheme.error),
                    title: Text('Logout',
                        style: TextStyle(color: colorScheme.error)),
                    subtitle: const Text('Clear selected demo user'),
                    onTap: () {
                      ref
                          .read<StateController<QuickUser?>>(
                            selectedUserProvider.notifier,
                          )
                          .state = null;
                      context.go(AppRoutes.userSelect);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Card(
              color: colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Defense note: auth is intentionally light. The backend trusts X-User-Id for this hackathon so time stays focused on preventing double-booking.',
                  style: TextStyle(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
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
