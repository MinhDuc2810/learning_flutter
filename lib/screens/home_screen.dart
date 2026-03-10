import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:base_flutter/theme/ons_color.dart';
import 'tabs/home_tab.dart';
import 'tabs/course_tab.dart';
import 'tabs/task_tab.dart';
import 'tabs/result_tab.dart';
import 'tabs/notification_tab.dart';

class HomeScreen extends StatefulWidget {
  final String username;
  const HomeScreen({
    super.key,
    required this.username,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          HomeTab(
            username: widget.username,
            onTabChange: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
          CourseTab(username: widget.username),
          TaskTab(username: widget.username),
          ResultTab(username: widget.username),
          NotificationTab(username: widget.username),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: HexColor(StringColor.primary1),
        unselectedItemColor: Colors.grey,
        selectedLabelStyle:
            const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        unselectedLabelStyle:
            const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        items: [
          BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: SvgPicture.asset('lib/assets/svg/bottom_home.svg',
                  width: 24, height: 24),
            ),
            activeIcon: Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: SvgPicture.asset('lib/assets/svg/bottom_home_active.svg',
                  width: 24, height: 24),
            ),
            label: 'Trang chủ',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: SvgPicture.asset('lib/assets/svg/bottom_course.svg',
                  width: 24, height: 24),
            ),
            activeIcon: Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: SvgPicture.asset('lib/assets/svg/bottom_course_active.svg',
                  width: 24, height: 24),
            ),
            label: 'Khoá học',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: SvgPicture.asset('lib/assets/svg/bottom_learning_task.svg',
                  width: 24, height: 24),
            ),
            activeIcon: Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: SvgPicture.asset(
                  'lib/assets/svg/bottom_learning_task_active.svg',
                  width: 24,
                  height: 24),
            ),
            label: 'Nhiệm vụ',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: SvgPicture.asset('lib/assets/svg/bottom_result.svg',
                  width: 24, height: 24),
            ),
            activeIcon: Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: SvgPicture.asset('lib/assets/svg/bottom_result_active.svg',
                  width: 24, height: 24),
            ),
            label: 'Kết quả',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: SvgPicture.asset('lib/assets/svg/bottom_notification.svg',
                  width: 24, height: 24),
            ),
            activeIcon: Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: SvgPicture.asset(
                  'lib/assets/svg/bottom_notification_active.svg',
                  width: 24,
                  height: 24),
            ),
            label: 'Thông báo',
          ),
        ],
      ),
    );
  }
}
