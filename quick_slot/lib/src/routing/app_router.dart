import 'package:go_router/go_router.dart';
import 'package:quick_slot/src/routing/global_navigator.dart';
import 'package:quick_slot/src/routing/app_routes.dart';

import 'package:quick_slot/src/features/auth/presentation/screens/login_screen.dart';
import 'package:quick_slot/src/features/auth/presentation/screens/signup_screen.dart';
import 'package:quick_slot/src/features/auth/presentation/screens/forgot_password_screen.dart';

import 'package:quick_slot/src/features/onboarding/presentation/screens/onboarding_page.dart';
import 'package:quick_slot/src/features/quickslot/data/quickslot_models.dart';
import 'package:quick_slot/src/features/quickslot/presentation/screens/booking_success_screen.dart';
import 'package:quick_slot/src/features/quickslot/presentation/screens/my_bookings_screen.dart';
import 'package:quick_slot/src/features/quickslot/presentation/screens/profile_screen.dart';
import 'package:quick_slot/src/features/quickslot/presentation/screens/splash_screen.dart';
import 'package:quick_slot/src/features/quickslot/presentation/screens/user_select_screen.dart';
import 'package:quick_slot/src/features/quickslot/presentation/screens/venue_detail_screen.dart';
import 'package:quick_slot/src/features/quickslot/presentation/screens/venue_list_screen.dart';

final GoRouter appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: AppRoutes.splash,
  routes: <RouteBase>[
    GoRoute(
      path: AppRoutes.splash,
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRoutes.userSelect,
      name: 'userSelect',
      builder: (context, state) => const UserSelectScreen(),
    ),
    GoRoute(
      path: AppRoutes.venues,
      name: 'venues',
      builder: (context, state) => const VenueListScreen(),
      routes: [
        GoRoute(
          path: ':venueId',
          name: 'venueDetail',
          builder: (context, state) {
            final venueId = int.parse(state.pathParameters['venueId']!);
            return VenueDetailScreen(venueId: venueId);
          },
        ),
      ],
    ),
    GoRoute(
      path: AppRoutes.bookings,
      name: 'bookings',
      builder: (context, state) => const MyBookingsScreen(),
    ),
    GoRoute(
      path: AppRoutes.bookingSuccess,
      name: 'bookingSuccess',
      builder: (context, state) {
        final booking = state.extra as Booking?;
        return BookingSuccessScreen(booking: booking);
      },
    ),
    GoRoute(
      path: AppRoutes.profile,
      name: 'profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: AppRoutes.onboarding,
      name: 'onboarding',
      builder: (context, state) => const OnboardingPage(),
    ),
    GoRoute(
      path: AppRoutes.login,
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: AppRoutes.signup,
      name: 'signup',
      builder: (context, state) => const SignupScreen(),
    ),
    GoRoute(
      path: AppRoutes.forgotPassword,
      name: 'forgotPassword',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
  ],
);
