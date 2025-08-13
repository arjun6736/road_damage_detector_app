import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_native_splash/flutter_native_splash.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    // Keep native splash while loading
    await Future.delayed(const Duration(seconds: 2));
    final prefs = await SharedPreferences.getInstance();

    final bool isNew = prefs.getBool('is_new_user') ?? true;
    final bool isLoggedIn = prefs.getBool('is_logged_in') ?? false;
    final bool isAdmin = prefs.getBool('is_admin') ?? false;
    debugPrint('isNew: $isNew');
    debugPrint('isLoggedIn: $isLoggedIn');
    debugPrint('isAdmin: $isAdmin');

    // Remove native splash right before navigation
    FlutterNativeSplash.remove();

    if (!mounted) return;

    if (isNew) {
      context.goNamed('intro');
      debugPrint('Navigating to Intro Screen');
    } else if (isLoggedIn) {
      if (isAdmin) {
        debugPrint('Navigating to Admin Dashboard');
        // context.goNamed('adminDashboard');
      } else {
        debugPrint('Navigating to User Dashboard');
        // context.goNamed('home');
      }
    } else {
      debugPrint('Navigating to Login Screen');
      // context.goNamed('login');
    }
  }

  @override
  Widget build(BuildContext context) {
    // No extra UI — native splash will cover this
    return Container(
      color: Colors.white, // match your native splash background
      alignment: Alignment.center,
    );
  }
}
