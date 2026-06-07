import 'package:flutter/material.dart';
import 'dashboard_screen.dart'; // Import màn hình trang chủ mới tạo
import 'register_screen.dart';
class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Định nghĩa các Controller để lấy dữ liệu nhập vào từ bàn phím
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _handleLogin() {
    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();

    // LOGIC CHECK TÀI KHOẢN TEST HỢP LỆ
    if (username == 'admin@vunven.com' && password == '12345678') {
      // Đăng nhập thành công -> Chuyển sang Trang Chủ Dashboard
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
      );
    } else {
      // Đăng nhập thất bại -> Hiển thị thông báo
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tài khoản hoặc mật khẩu test không đúng! (Gợi ý: admin@vunven.com / 12345678)'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF10B981),
      body: Column(
        children: [
          const SizedBox(height: 60),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 30.0, horizontal: 40.0),
            child: Text(
              '“Vun Vén Từng Đồng\nAn Lòng Từng Bước”',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF064E3B), height: 1.3),
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFFF2FBF7),
                borderRadius: BorderRadius.only(topLeft: Radius.circular(60), topRight: Radius.circular(60)),
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 35.0, vertical: 40.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Tên Tài Khoản', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black54, fontSize: 15)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _usernameController, // Gắn bộ lắng nghe dữ liệu
                        decoration: InputDecoration(
                          hintText: 'admin@vunven.com',
                          hintStyle: const TextStyle(color: Colors.black26),
                          filled: true,
                          fillColor: const Color(0xFFE2F6EE),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text('Mật Khẩu', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black54, fontSize: 15)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _passwordController, // Gắn bộ lắng nghe dữ liệu
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: '••••••••',
                          hintStyle: const TextStyle(color: Colors.black38),
                          filled: true,
                          fillColor: const Color(0xFFE2F6EE),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          suffixIcon: const Padding(
                            padding: EdgeInsets.only(right: 12.0),
                            child: Icon(Icons.visibility_off_outlined, color: Colors.black45),
                          ),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Nút Đăng Nhập đã được gắn hàm kích hoạt logic xử lý _handleLogin
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF10B981),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                          ),
                          onPressed: _handleLogin, // Gọi hàm xác thực khi bấm nút
                          child: const Text('Đăng Nhập', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      Center(
                        child: TextButton(
                          onPressed: () {},
                          child: const Text('Quên mật khẩu?', style: TextStyle(color: Colors.black54, fontSize: 14)),
                        ),
                      ),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE2F6EE),
                            foregroundColor: Colors.black87,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                          ),
                          onPressed: () {},
                          child: const Text('Đăng Ký', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: TextButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.fingerprint, color: Color(0xFF0D9488)),
                          label: const Text('Đăng Nhập Với FaceID', style: TextStyle(color: Color(0xFF0D9488), fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(height: 15),
                      const Center(child: Text('Đăng nhập với', style: TextStyle(color: Colors.black38, fontSize: 13))),
                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildSocialButton(Icons.facebook, Colors.blue[800]!),
                          const SizedBox(width: 25),
                          _buildSocialButton(Icons.g_mobiledata_rounded, Colors.redAccent),
                        ],
                      ),
                      const SizedBox(height: 25),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Bạn chưa có tài khoản? ', style: TextStyle(color: Colors.black45)),
                          GestureDetector(
                            onTap: () {},
                            child: const Text('Sign Up', style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold)),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.black12), color: Colors.white),
      child: Icon(icon, size: 32, color: color),
    );
  }


}