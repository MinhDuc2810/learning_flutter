import 'package:flutter/material.dart';
import 'package:base_flutter/app_routes.dart';
import 'package:base_flutter/theme/ons_color.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: HexColor(StringColor.primary1)),
        useMaterial3: true,
      ),
      initialRoute: '/login',
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}
