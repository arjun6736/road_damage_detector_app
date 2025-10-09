// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'package:flutter/material.dart';
import 'package:routefixer/screens/home.dart';
import 'package:routefixer/screens/notificationscreen.dart';
import 'package:routefixer/screens/profilescreen.dart';
import 'package:routefixer/screens/repoartscreen.dart';

// Camara Service
import 'package:camera/camera.dart';
import 'package:routefixer/services/cameraservice.dart';
//end of Camara Service

class MainPage extends StatefulWidget {
  final List<CameraDescription> cameras;
  const MainPage({super.key, required this.cameras});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;
  // ignore: unused_field
  late Future<void> _cameraInitFuture;

  @override
  void initState() {
    super.initState();
    // Start camera initialization in background
    _cameraInitFuture = CameraService().init(widget.cameras.first);
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _screens = const [
      Home(),
      Repoartscreen(),
      NotificationsPage(),
      ProfilePage(),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        elevation: 18,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.report), label: 'Reports'),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
