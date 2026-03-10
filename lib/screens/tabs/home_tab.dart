import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../theme/ons_color.dart';
import '../../data_providers/home_api.dart';

class HomeTab extends StatefulWidget {
  final String username;
  final Function(int)? onTabChange;

  const HomeTab({
    super.key,
    required this.username,
    this.onTabChange,
  });

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final HomeAPI _homeAPI = HomeAPI();
  String? _logoUrl;

  @override
  void initState() {
    super.initState();
    _fetchLogo();
  }

  Future<void> _fetchLogo() async {
    try {
      final result = await _homeAPI.getLogoHome();
      if (result['success'] == true && result['data'] != null) {
        setState(() {
          _logoUrl = result['data']['imageurl'];
        });
      } else if (result['imageurl'] != null) {
        setState(() {
          _logoUrl = result['imageurl'];
        });
      }
    } catch (e) {
      debugPrint('Error fetching logo: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      body: SingleChildScrollView(
        // Use physics to ensure smooth scrolling
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 10),
            // Floating indicator
            Center(
              child: Container(
                width: 32,
                height: 4,
                decoration: BoxDecoration(
                  color: HexColor(StringColor.primary1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildMainFunctions(),
            const SizedBox(height: 24),
            _buildBanner(),
            const SizedBox(height: 24),
            _buildSectionTitle('Tin tức'),
            const SizedBox(
                height:
                    80), // Extra space at bottom to avoid overlap with BottomNav
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Stack(
      children: [
        // Background Image with dark overlay for better text contrast
        Container(
          height: 260,
          width: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('lib/assets/image/homeTabBackground.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.2),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        // Content
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Row: Logo and Profile/Logout
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (_logoUrl != null)
                      Image.network(
                        _logoUrl!,
                        height: 45,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) =>
                            const SizedBox(height: 45),
                      )
                    else
                      const SizedBox(height: 45),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.person_outline,
                              color: Colors.white, size: 28),
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              '/profile',
                              arguments: {'username': widget.username},
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.logout,
                              color: Colors.white, size: 28),
                          onPressed: () => _showLogoutDialog(context),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                // Welcome Section
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const CircleAvatar(
                        radius: 35,
                        backgroundColor: Color(0xFFE0E0E0),
                        child:
                            Icon(Icons.person, size: 50, color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Xin chào,',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Text(
                          widget.username,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMainFunctions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'Chức năng chính',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: HexColor(StringColor.primary1),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildGridItem(
                'Khóa học',
                'lib/assets/svg/grid_course.svg',
                onTap: () => widget.onTabChange?.call(1),
              ),
              _buildGridItem(
                'Nhiệm vụ',
                'lib/assets/svg/grid_mission.svg',
                onTap: () => widget.onTabChange?.call(2),
              ),
              _buildGridItem(
                'Kết quả học',
                'lib/assets/svg/grid_test_result.svg',
                onTap: () => widget.onTabChange?.call(3),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGridItem(String title, String svgPath, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 80, // Increased size slightly
            height: 80,
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: SvgPicture.asset(
              svgPath,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1F2937),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.asset(
          'lib/assets/image/banner.png',
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            height: 150,
            width: double.infinity,
            color: Colors.grey[300],
            child: const Icon(Icons.image_not_supported, color: Colors.grey),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: HexColor(StringColor.primary1),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Center(
            child: Text(
              'Notification',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Đóng', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.pushReplacementNamed(context, '/login'),
              child: Text('Đăng xuất',
                  style: TextStyle(color: HexColor(StringColor.primary1))),
            ),
          ],
        );
      },
    );
  }
}
