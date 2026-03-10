import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:base_flutter/data_providers/home_api.dart';
import 'package:base_flutter/data_providers/auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:base_flutter/theme/ons_color.dart';
import 'package:base_flutter/theme/gaps.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _logoUrl;
  final HomeAPI _homeAPI = HomeAPI();

  @override
  void initState() {
    super.initState();
    _fetchLogo();
  }

  Future<void> _fetchLogo() async {
    try {
      final result = await _homeAPI.getlogologin();
      if (result['success'] == true && result['data'] != null) {
        setState(() {
          _logoUrl = result['data']['imageurl'];
        });
      }
    } catch (e) {
      debugPrint('Error fetching logo: $e');
    }
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final username = _usernameController.text;
      final password = _passwordController.text;

      try {
        final result = await AuthAPI.login(
          username: username,
          password: password,
        );

        if (result['token'] != null) {
          // Lưu token vào local storage
       try {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('token', result['token']);
          } catch (e) {
            debugPrint('Error saving preferences: $e');
          }

          if (!mounted) return;
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/home',
            (route) => false,
            arguments: {
              'username': username,
            },
          );
        } else {
          if (!mounted) return;
          setState(() {
            _isLoading = false;
          });
          String errorMsg = result['error'] ?? 'Sai tài khoản hoặc mật khẩu';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: const Color.fromARGB(255, 253, 58, 45),
              content: Text(errorMsg),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color.fromARGB(255, 253, 58, 45),
            content: Text('Lỗi kết nối: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showNotification() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: BoxDecoration(
          color: HexColor(StringColor.loginNofi),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 16,
              right: 16,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.grey),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),
                  Center(
                    child: SvgPicture.asset(
                      'lib/assets/svg/thongbao_login.svg',
                    ),
                  ),
                  // Thêm nội dung thông báo khác ở đây nếu cần
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 60), // Space from top to logo
                    // Large Logo from API
                    if (_logoUrl != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20.0),
                        child: Image.network(
                          _logoUrl!,
                          width: 250,
                          height: 80,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.school,
                                  size: 80, color: Colors.indigo),
                        ),
                      )
                    else
                      const SizedBox(height: 130),

                    Gaps.vGap24,

                    // Username Group
                    const Text(
                      'Tài khoản',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Gaps.vGap8,
                    TextFormField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        hintText: 'Tài khoản của bạn',
                        hintStyle: TextStyle(
                            color: Colors.grey.shade400, fontSize: 15),
                        filled: true,
                        fillColor: const Color(0xFFFCFCFE),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              BorderSide(color: HexColor(StringColor.primary1)),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập tài khoản';
                        }
                        return null;
                      },
                    ),
                    Gaps.vGap20,

                    // Password Group
                    const Text(
                      'Mật khẩu',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Gaps.vGap8,
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        hintText: 'Mật khẩu của bạn',
                        hintStyle: TextStyle(
                            color: Colors.grey.shade400, fontSize: 15),
                        filled: true,
                        fillColor: const Color(0xFFFCFCFE),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: Colors.grey,
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              BorderSide(color: HexColor(StringColor.primary1)),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập mật khẩu';
                        }
                        return null;
                      },
                    ),
                    Gaps.vGap32,

                    // Login Button
                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: HexColor(StringColor.primary1),
                          foregroundColor: Colors.white,
                          disabledBackgroundColor:
                              HexColor(StringColor.primary1).withOpacity(0.7),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'ĐĂNG NHẬP',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.8,
                                ),
                              ),
                      ),
                    ),
                    Gaps.vGap16,

                    // Bottom Links
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: _showNotification,
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(0, 30),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'Thông báo',
                            style: TextStyle(
                              color: Color(0xFF282A75),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/forgot_password');
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(0, 30),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'Quên mật khẩu?',
                            style: TextStyle(
                              color: Color(0xFF282A75),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Top Right SVG Icon
            Positioned(
              top: 10,
              right: 20,
              child: GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/setting');
                },
                child: SvgPicture.asset(
                  'lib/assets/svg/user_setting.svg',
                  color: HexColor(StringColor.primary1),
                  width: 32,
                  height: 32,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
