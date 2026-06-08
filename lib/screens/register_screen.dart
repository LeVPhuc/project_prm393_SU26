import 'package:flutter/material.dart';
import 'registration_success_screen.dart'; // Import màn hình thành công đã tạo

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passController = TextEditingController();
  final _confirmPassController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _agreedToTerms = false;

  final Color primaryColor = const Color(0xFF00875A);

  void _handleRegister() {
    // 1. Kiểm tra validation của Form
    if (!_formKey.currentState!.validate()) return;

    // 2. Kiểm tra điều khoản
    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Vui lòng đồng ý với điều khoản sử dụng!"),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // 3. Kiểm tra mật khẩu khớp nhau
    if (_passController.text != _confirmPassController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Mật khẩu xác nhận không khớp!"),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // 4. Chuyển hướng sang màn hình Thành công
    // Dữ liệu từ các Controller được truyền qua constructor
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RegistrationSuccessScreen(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Form( // Bọc trong Form
          key: _formKey,
          child: Column(
            children: [
              // --- HEADER XANH ---
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(top: 60, bottom: 30),
                decoration: BoxDecoration(color: primaryColor, borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30))),
                child: Column(
                  children: const [
                    Text("Tạo tài khoản", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text("Vun Vén Từng Đồng - An Lòng Từng Bước", style: TextStyle(color: Colors.white70, fontSize: 14)),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextField("Họ và tên", Icons.person_outline, _nameController),
                    _buildTextField("Email", Icons.email_outlined, _emailController),
                    _buildTextField("Số điện thoại", Icons.phone_android_outlined, _phoneController),
                    _buildTextField("Mật khẩu", Icons.lock_outline, _passController, isPassword: true, isVisible: _isPasswordVisible, onToggle: () => setState(() => _isPasswordVisible = !_isPasswordVisible)),
                    _buildTextField("Xác nhận mật khẩu", Icons.lock_outline, _confirmPassController, isPassword: true, isVisible: _isConfirmPasswordVisible, onToggle: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible)),

                    // Checkbox
                    Row(
                      children: [
                        Checkbox(value: _agreedToTerms, activeColor: primaryColor, onChanged: (val) => setState(() => _agreedToTerms = val!)),
                        const Expanded(child: Text("Tôi đồng ý với điều khoản sử dụng và chính sách bảo mật", style: TextStyle(fontSize: 12))),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Nút Đăng ký
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _handleRegister,
                        style: ElevatedButton.styleFrom(backgroundColor: primaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                        child: const Text("Đăng Ký", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, IconData icon, TextEditingController controller, {bool isPassword = false, bool isVisible = false, VoidCallback? onToggle}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: isPassword && !isVisible,
          validator: (value) => value!.isEmpty ? "Vui lòng nhập $label" : null,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.grey),
            suffixIcon: isPassword ? IconButton(icon: Icon(isVisible ? Icons.visibility : Icons.visibility_off), onPressed: onToggle) : null,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}