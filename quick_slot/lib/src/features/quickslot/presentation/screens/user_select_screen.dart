import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quick_slot/src/features/quickslot/presentation/providers/quickslot_providers.dart';
import 'package:quick_slot/src/routing/app_routes.dart';

class UserSelectScreen extends ConsumerWidget {
  const UserSelectScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 36),
              Icon(Icons.sports_tennis_rounded, size: 52, color: colorScheme.primary),
              const SizedBox(height: 18),
              Text(
                'QuickSlot',
                style: textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                'Pick a demo user to book courts and turfs.',
                style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: ListView.separated(
                  itemCount: demoUsers.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final user = demoUsers[index];
                    return Card(
                      margin: EdgeInsets.zero,
                      child: ListTile(
                        leading: CircleAvatar(child: Text(user.name.characters.first)),
                        title: Text(user.name),
                        subtitle: Text('User id: ${user.id}'),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () {
                          ref.read(selectedUserProvider.notifier).state = user;
                          context.go(AppRoutes.venues);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
