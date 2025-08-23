import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:routefixer/app_theme.dart';
import 'package:routefixer/routes.dart';
// import 'firebase_options.dart';
// import 'package:routefixer/screens/splashscreen.dart';

void main() async {
  WidgetsBinding binding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: binding);
  WidgetsFlutterBinding.ensureInitialized(); //firebase
  await Firebase.initializeApp(
    // options: DefaultFirebaseOptions.currentPlatform,
  ); //firebase
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Road Damage Detection',
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}
