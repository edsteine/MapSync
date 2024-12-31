// lib/features/splash/splash_screen.dart
///
/// File: lib/features/splash/splash_screen.dart
/// Author: Adil AJDAA
/// Email: a.ajdaa@outlook.com
/// Purpose: Displays a splash screen with a logo and navigates to the main map screen.
/// Updates: Initial setup for splash screen with a timer-based navigation to the map screen.
/// Used Libraries: flutter/material.dart, flutter_riverpod/flutter_riverpod.dart, mobile/core/config/app_routes.dart
///
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/config/app_routes.dart';

/// A simple splash screen that navigates to the main map screen after a short delay.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Start a timer to navigate to the map screen after a delay.
    Future.delayed(const Duration(seconds: 2), () {
       // Navigates to the map route.
      Navigator.of(context).pushReplacementNamed(AppRoutes.map);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Add a placeholder logo here, using a SizedBox for demonstration
            SizedBox(
              width: 150,
              height: 150,
               // Shows a placeholder Icon for the logo
              child: Icon(Icons.map, size: 100, color: Theme.of(context).colorScheme.primary,),
            ),
            const SizedBox(height: 20),
              // Add a placeholder text
             Text(
                'Offline Maps',
                style: Theme.of(context).textTheme.titleLarge,
              )
          ],
        ),
      ),
    );
  }
}