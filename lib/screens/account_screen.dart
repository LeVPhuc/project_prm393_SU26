import 'package:flutter/material.dart';

class AccountScreen extends StatelessWidget {
  final String userName;

  const AccountScreen({Key? key, required this.userName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Scaffold ở đây chỉ chứa AppBar và Body.
    // Navigation bar và FAB đã nằm ở MainWrapper.
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text("Tài khoản", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
        centerTitle: true,
        // Nút quay lại điều hướng về trang trước
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const CircleAvatar(
              radius: 50,
              backgroundColor: Color(0xFF00875A),
              child: Icon(Icons.person, size: 60, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(
              "Xin chào, $userName!",
              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            _buildMenuItem(Icons.edit, "Thông tin cá nhân", "Cập nhật thông tin cơ bản"),
            _buildMenuItem(Icons.settings, "Cài đặt tài khoản", "Quản lý thông báo, ngôn ngữ"),
            _buildMenuItem(Icons.account_balance, "Ngân hàng liên kết", "Thêm hoặc hủy kết nối ngân hàng"),
            _buildMenuItem(Icons.card_giftcard, "Mã giới thiệu", "Nhận quà khi mời bạn bè"),
            _buildMenuItem(Icons.lock, "Bảo mật", "Quản lý mật khẩu, sinh trắc học"),
            _buildMenuItem(Icons.info_outline, "Hỗ trợ & Trợ giúp", "Câu hỏi thường gặp & liên hệ"),
            _buildMenuItem(Icons.article, "Về ứng dụng", "Điều khoản & chính sách bảo mật"),
            const SizedBox(height: 10),
            _buildMenuItem(Icons.logout, "Đăng xuất", "Thoát khỏi phiên đăng nhập hiện tại", color: Colors.redAccent),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, String subtitle, {Color color = Colors.white}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: Icon(icon, color: color, size: 24),
        title: Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text(subtitle, style: TextStyle(color: color.withOpacity(0.6), fontSize: 11)),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
        onTap: () {},
      ),
    );
  }
}