import 'package:go_router/go_router.dart';

import '../../features/auth/login_screen.dart';
import '../../features/navigation/main_navigation_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/splash/splash_screen.dart';

final GoRouter router = GoRouter(
  initialLocation: '/',

  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) {
        return const SplashScreen();
      },
    ),

    GoRoute(
      path: '/onboarding',
      builder: (context, state) {
        return const OnboardingScreen();
      },
    ),

    GoRoute(
      path: '/login',
      builder: (context, state) {
        return const LoginScreen();
      },
    ),

    GoRoute(
      path: '/main',
      builder: (context, state) {
        return const MainNavigationScreen();
      },
    ),
  ],
);