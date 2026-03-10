import 'package:flutter/material.dart';

class CourseTab extends StatelessWidget {
  final String username;
  const CourseTab({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Khoá học',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline, color: Colors.black87),
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/profile',
                arguments: {'username': username},
              );
            },
          ),
        ],
      ),
      body: const Center(
        child: Text('Khoá học content'),
      ),
    );
  }
}
