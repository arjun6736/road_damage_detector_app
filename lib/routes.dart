import 'package:camera/camera.dart';
import 'package:go_router/go_router.dart';
import 'package:routefixer/navigation/main_page.dart';
import 'package:routefixer/screens/add_details_cap.dart';
import 'package:routefixer/screens/admin_login.dart';
import 'package:routefixer/screens/resetpassword.dart';
import 'package:routefixer/screens/user_login.dart';
import 'package:routefixer/screens/user_signup.dart';
import 'package:routefixer/services/capturescreen.dart';
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
      path: '/mainpage',
      name: 'mainpage',
      builder: (context, state) => const MainPage(),
    ),
    GoRoute(
      path: '/signup',
      name: 'signup',
      builder: (context, state) => const UserSignup(),
    ),
    GoRoute(
      path: '/reset-password',
      name: 'reset-password',
      builder: (context, state) => const ResetPasswordPage(),
    ),
    GoRoute(
      path: '/admin_login',
      name: 'admin_login',
      builder: (context, state) => const AdminLogin(),
    ),
    GoRoute(
      path: '/capture',
      name: 'capture',
      builder: (context, state) {
        final camera = state.extra as CameraDescription;
        return CapturePage(camera: camera);
      },
    ),
    GoRoute(
      path: '/add-details',
      name: 'addDetails',
      builder: (context, state) {
        final args = state.extra as Map<String, dynamic>;
        return AddDetailsPage(
          imageFile: args['imageFile'],
          gps: args['gps'],
          time: args['time'],
        );
      },
    ),
  ],
);
