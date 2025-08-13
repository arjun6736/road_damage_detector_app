import 'package:go_router/go_router.dart';
import 'package:routefixer/screens/home.dart';
import 'package:routefixer/screens/user_login.dart';
import 'package:routefixer/screens/user_signup.dart';
import 'screens/splashscreen.dart';
import 'screens/introscreen.dart';
// import 'screens/home_screen.dart';
// import 'screens/login_screen.dart';

final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/intro',
      name: 'intro',
      builder: (context, state) => const IntroScreen(),
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const UserLogin(),
    ),
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) => const Home(),
    ),
    GoRoute(
      path: '/signup',
      name: 'signup',
      builder: (context, state) => const UserSignup(),
    ),
  ],
);
