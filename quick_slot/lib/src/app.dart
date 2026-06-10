import 'package:quick_slot/src/imports/core_imports.dart';
import 'package:quick_slot/src/imports/packages_imports.dart';
import 'package:quick_slot/src/features/quickslot/presentation/providers/quickslot_providers.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch<ThemeMode>(themeModeProvider);
    final current = _buildMaterialApp(context, themeMode);
    return ScreenUtilWrapper(child: current);
  }

  Widget _buildMaterialApp(BuildContext context, ThemeMode themeMode) {
    return MaterialApp.router(
      title: 'QuickSlot',
      debugShowCheckedModeBanner: false,
      theme: buildLightTheme(primaryColorHex: '#2563EB'),
      darkTheme: buildDarkTheme(primaryColorHex: '#2563EB'),
      themeMode: themeMode,
      routerConfig: appRouter,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      builder: (context, child) {
        Widget current = child!;
        current = SkeletonWrapper(child: current);
        return current;
      },
    );
  }
}
