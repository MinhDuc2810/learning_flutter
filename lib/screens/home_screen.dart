import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  final String username;
  final String password;
  const HomeScreen({super.key, required this.username, required this.password});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Home Screen'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/profile',
                arguments: {
                  'username': username,
                  'password': password,
                },
              );
            },
          ),
        ],
      ),
      body: const Center(),
    );
  }
}
