import 'package:flutter/material.dart';
import 'package:base_flutter/theme/ons_color.dart';
import 'package:base_flutter/theme/gaps.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  double _fontSize = 1.0;

  @override
  Widget build(BuildContext context) {
    final primaryColor = HexColor(StringColor.primary1);

    return Scaffold(
      backgroundColor: const Color(0xFFEEEEEE),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Cài đặt',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cài đặt cơ bản',
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Gaps.vGap16,
                  _buildSettingItem(
                    title: 'Cỡ chữ',
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () {
                            setState(() {
                              if (_fontSize > 0.5) _fontSize -= 0.1;
                            });
                          },
                          icon: const Icon(Icons.remove, color: Colors.red),
                        ),
                        Text(
                          _fontSize.toStringAsFixed(1),
                          style: const TextStyle(fontSize: 16),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _fontSize += 0.1;
                            });
                          },
                          icon: const Icon(Icons.add, color: Colors.green),
                        ),
                      ],
                    ),
                  ),
                  Gaps.vGap12,
                  _buildSettingItem(
                    title: 'Xóa bộ nhớ đệm',
                    trailing: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.delete, color: Colors.red),
                      ),
                    ),
                  ),
                  Gaps.vGap12,
                  _buildSettingItem(
                    title: 'Cấp quyền cho ứng dụng',
                    trailing: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.settings, color: primaryColor),
                      ),
                    ),
                  ),
                  Gaps.vGap24,
                  Text(
                    'Cài đặt nâng cao',
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Gaps.vGap16,
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Cần đăng nhập để mở cài đặt nâng cao.',
                      style: TextStyle(color: primaryColor, fontSize: 15),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Lưu cài đặt',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({required String title, required Widget trailing}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
          trailing,
        ],
      ),
    );
  }
}
