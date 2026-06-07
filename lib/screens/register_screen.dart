import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _agreedToTerms = false;

  final Color primaryColor = const Color(0xFF00875A); // Màu xanh lục chủ đạo của ảnh

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- HEADER XANH ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 60, bottom: 30),
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  const Text(
                    "Tạo tài khoản",
                    style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Vun Vén Từng Đồng - An Lòng Từng Bước",
                    style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Họ và tên
                  _buildLabel("Họ và tên"),
                  _buildTextField("Nhập họ và tên của bạn", Icons.person_outline),

                  // Email
                  _buildLabel("Email"),
                  _buildTextField("Nhập email của bạn", Icons.email_outlined),

                  // Số điện thoại
                  _buildLabel("Số điện thoại"),
                  _buildTextField("Nhập số điện thoại của bạn", Icons.phone_android_outlined),

                  // Mật khẩu
                  _buildLabel("Mật khẩu"),
                  _buildTextField(
                    "Nhập mật khẩu",
                    Icons.lock_outline,
                    isPassword: true,
                    isVisible: _isPasswordVisible,
                    onToggle: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 8, bottom: 16),
                    child: Text(
                      "Mật khẩu phải có ít nhất 8 ký tự, bao gồm chữ, số và ký tự đặc biệt",
                      style: TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                  ),

                  // Xác nhận mật khẩu
                  _buildLabel("Xác nhận mật khẩu"),
                  _buildTextField(
                    "Nhập lại mật khẩu",
                    Icons.lock_outline,
                    isPassword: true,
                    isVisible: _isConfirmPasswordVisible,
                    onToggle: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
                  ),

                  const SizedBox(height: 10),

                  // Checkbox Điều khoản
                  Row(
                    children: [
                      Checkbox(
                        value: _agreedToTerms,
                        activeColor: primaryColor,
                        onChanged: (val) => setState(() => _agreedToTerms = val!),
                      ),
                      const Expanded(
                        child: Text.rich(
                          TextSpan(
                            text: "Tôi đồng ý với ",
                            style: TextStyle(fontSize: 13),
                            children: [
                              TextSpan(text: "Điều khoản sử dụng", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                              TextSpan(text: " và "),
                              TextSpan(text: "Chính sách bảo mật", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Nút Đăng ký
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text("Đăng Ký", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // Đăng ký với MXH
                  const Center(child: Text("Hoặc đăng ký với", style: TextStyle(color: Colors.grey))),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildSocialButton("assets/facebook_logo.png"), // Bạn cần thêm ảnh vào assets
                      const SizedBox(width: 20),
                      _buildSocialButton("assets/google_logo.png"),
                    ],
                  ),

                  const SizedBox(height: 25),

                  // Footer chuyển sang Đăng nhập
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Đã có tài khoản? "),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Text("Đăng nhập", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET HỖ TRỢ ---
  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
    );
  }

  Widget _buildTextField(String hint, IconData icon, {bool isPassword = false, bool? isVisible, VoidCallback? onToggle}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: TextField(
        obscureText: isPassword ? !(isVisible ?? false) : false,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
          prefixIcon: Icon(icon, color: Colors.grey),
          suffixIcon: isPassword
              ? IconButton(
            icon: Icon(isVisible! ? Icons.visibility : Icons.visibility_off, color: Colors.grey),
            onPressed: onToggle,
          )
              : null,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: primaryColor, width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton(String assetPath) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Image.network( // Tạm dùng network để bạn dễ test, sau này dùng Image.asset
        assetPath == "assets/google_logo.png"
            ? "https://cdn-icons-png.flaticon.com/512/2991/2991148.png"
            : "https://cdn-icons-png.flaticon.com/512/733/733547.png",
        width: 24,
        height: 24,
      ),
    );
  }
}