import 'package:flutter/material.dart';

class Repoartscreen extends StatelessWidget {
  const Repoartscreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Reports Screen',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
