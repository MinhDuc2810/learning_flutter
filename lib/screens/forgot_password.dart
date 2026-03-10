import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:base_flutter/theme/ons_color.dart';
import 'package:base_flutter/theme/gaps.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isInputEmpty = true;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_onInputChanged);
  }

  void _onInputChanged() {
    setState(() {
      _isInputEmpty = _emailController.text.trim().isEmpty;
    });
  }

  @override
  void dispose() {
    _emailController.removeListener(_onInputChanged);
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Quên mật khẩu',
          style: TextStyle(
            color: HexColor(StringColor.primary1),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.grey),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
        ],
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Gaps.vGap24,
                Gaps.vGap16,
                // Illustration Banner
                Center(
                  child: SvgPicture.asset(
                    'lib/assets/svg/forgot_password_banner.svg',
                    fit: BoxFit.contain,
                  ),
                ),
                Gaps.vGap40,
                // Instruction Text
                const Text(
                  'Vui lòng nhập tên tài khoản hoặc email để đặt lại mật khẩu.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Gaps.vGap40,
                // Input Label
                const Text(
                  'Tài khoản / Email',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Gaps.vGap8,
                // Input Field
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    hintText: 'Tài khoản / Email của bạn',
                    hintStyle:
                        TextStyle(color: Colors.grey.shade400, fontSize: 15),
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
                      return 'Vui lòng nhập tài khoản hoặc email';
                    }
                    return null;
                  },
                ),
                Gaps.vGap32,
                // Submit Button
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isInputEmpty
                        ? null
                        : () {
                            if (_formKey.currentState!.validate()) {
                              // Handle confirmation logic
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isInputEmpty
                          ? const Color(0xFFE0E0E0)
                          : HexColor(StringColor.primary1),
                      disabledBackgroundColor: const Color(0xFFE0E0E0),
                      foregroundColor: Colors.white,
                      disabledForegroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Xác nhận',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
