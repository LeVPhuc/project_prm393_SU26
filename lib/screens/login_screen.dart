import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Đồng bộ màu nền xanh lá tươi tắn ở đỉnh trên cùng theo bản thiết kế
      backgroundColor: const Color(0xFF10B981),
      body: Column(
        children: [
          const SizedBox(height: 60),
          // PHẦN TIÊU ĐỀ: Slogan chữ lớn màu đen trên nền xanh theo đúng UI mẫu
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 30.0, horizontal: 40.0),
            child: Text(
              '“Vun Vén Từng Đồng\nAn Lòng Từng Bước”',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF064E3B), // Chữ xanh đậm quý phái
                height: 1.3,
              ),
            ),
          ),

          // PHẦN THÂN: Khung nền trắng bo cong chứa toàn bộ form nhập liệu
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFFF2FBF7), // Màu nền xám trắng ánh xanh nhẹ của form
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(60),   // Bo tròn góc lớn bên trái
                  topRight: Radius.circular(60),  // Bo tròn góc lớn bên phải
                ),
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 35.0, vertical: 40.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Ô nhập Tên Tài Khoản
                      const Text(
                        'Tên Tài Khoản',
                        style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black54, fontSize: 15),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        decoration: InputDecoration(
                          hintText: 'example@example.com',
                          hintStyle: const TextStyle(color: Colors.black26),
                          filled: true,
                          fillColor: const Color(0xFFE2F6EE), // Màu ô nhập xanh pastel nhẹ
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Ô nhập Mật Khẩu
                      const Text(
                        'Mật Khẩu',
                        style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black54, fontSize: 15),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
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
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Nút Đăng Nhập lớn màu xanh ngọc tươi
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF10B981),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          onPressed: () {},
                          child: const Text(
                            'Đăng Nhập',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),

                      // Quên mật khẩu
                      Center(
                        child: TextButton(
                          onPressed: () {},
                          child: const Text(
                            'Quên mật khẩu?',
                            style: TextStyle(color: Colors.black54, fontSize: 14),
                          ),
                        ),
                      ),

                      // Nút Đăng Ký (Đã sửa lỗi màu blackDE)
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE2F6EE),
                            foregroundColor: Colors.black87, // Sử dụng màu đen mờ 87% chuẩn Flutter
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          onPressed: () {},
                          child: const Text(
                            'Đăng Ký',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),

                      // Tính năng nâng cao: Đăng nhập với FaceID
                      Center(
                        child: TextButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.fingerprint, color: Color(0xFF0D9488)),
                          label: const Text(
                            'Đăng Nhập Với FaceID',
                            style: TextStyle(color: Color(0xFF0D9488), fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),

                      // Phân đoạn đăng nhập MXH
                      const Center(
                        child: Text(
                          'Đăng nhập với',
                          style: TextStyle(color: Colors.black38, fontSize: 13),
                        ),
                      ),
                      const SizedBox(height: 15),

                      // Bộ đôi nút biểu tượng mạng xã hội (Facebook, Google)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildSocialButton(Icons.facebook, Colors.blue[800]!),
                          const SizedBox(width: 25),
                          _buildSocialButton(Icons.g_mobiledata_rounded, Colors.redAccent),
                        ],
                      ),
                      const SizedBox(height: 25),

                      // Dòng chữ điều hướng đăng ký cuối cùng (Đã sửa đổi sang onTap chuẩn xác)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Bạn chưa có tài khoản? ', style: TextStyle(color: Colors.black45)),
                          GestureDetector(
                            onTap: () {
                              // Xử lý sự kiện chuyển sang trang đăng ký tại đây
                            },
                            child: const Text(
                              'Sign Up',
                              style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold),
                            ),
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

  // Hàm bổ trợ vẽ nhanh nút MXH bo tròn tinh tế
  Widget _buildSocialButton(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black12),
        color: Colors.white,
      ),
      child: Icon(icon, size: 32, color: color),
    );
  }
}