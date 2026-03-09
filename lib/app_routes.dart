import 'package:flutter/material.dart';
import 'package:base_flutter/screens/login_screens.dart';
import 'package:base_flutter/screens/home_screen.dart';
import 'package:base_flutter/screens/profile_screen.dart';

class AppRoutes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case '/':
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case '/home':
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => HomeScreen(
            username: args['username'] as String,
            password: args['password'] as String,
          ),
        );
      case '/profile':
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => ProfileScreen(
            username: args['username'] as String,
            password: args['password'] as String,
          ),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
