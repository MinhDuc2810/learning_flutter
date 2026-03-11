import 'package:flutter/material.dart';
import 'package:base_flutter/screens/login_screens.dart';
import 'package:base_flutter/screens/home_screen.dart';
import 'package:base_flutter/screens/profile_screen.dart';
import 'package:base_flutter/screens/forgot_password.dart';
import 'package:base_flutter/screens/setting_screen.dart';
import 'package:base_flutter/screens/course_detail_screen.dart';

class AppRoutes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case '/':
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case '/forgot_password':
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
      case '/setting':
        return MaterialPageRoute(builder: (_) => const SettingScreen());
      case '/home':
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => HomeScreen(
            username: args['username'] as String,
          ),
        );
      case '/profile':
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => ProfileScreen(
            username: args['username'] as String,
          ),
        );
      case '/course_detail':
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => CourseDetailScreen(
            courseId: args['courseId'] as String,
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
