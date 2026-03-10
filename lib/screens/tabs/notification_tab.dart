import 'package:flutter/material.dart';

class NotificationTab extends StatelessWidget {
  final String username;
  const NotificationTab({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Thông báo',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.black87),
            onPressed: () {
              // Custom action for notifications
            },
          ),
        ],
      ),
      body: const Center(
        child: Text('Thông báo content'),
      ),
    );
  }
}
