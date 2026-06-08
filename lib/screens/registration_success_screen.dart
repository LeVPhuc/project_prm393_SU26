import 'package:flutter/material.dart';
// 1. Import màn hình GoalSelectionScreen của bạn
import 'goal_selection_screen.dart';

class RegistrationSuccessScreen extends StatelessWidget {
  final String name;
  final String email;
  final String phone;

  const RegistrationSuccessScreen({
    Key? key,
    required this.name,
    required this.email,
    required this.phone,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 40),
              // Header giữ nguyên
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(width: 150, height: 150, decoration: BoxDecoration(color: Colors.green.withOpacity(0.05), shape: BoxShape.circle)),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle),
                      child: const Icon(Icons.check, size: 60, color: Colors.white),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text('Đăng ký tài khoản thành công!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF064E3B))),
              const SizedBox(height: 12),
              const Text('Chào mừng bạn đến với Vun Vén. Hãy bắt đầu quản lý tài chính cá nhân của bạn ngay hôm nay.', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Colors.black54, height: 1.5)),
              const SizedBox(height: 40),

              _buildSectionTitle('Thông tin tài khoản'),
              const SizedBox(height: 16),
              _buildInfoRow(Icons.person_outline, 'Họ và tên', name),
              _buildInfoRow(Icons.mail_outline, 'Email', email),
              _buildInfoRow(Icons.phone_android_outlined, 'Số điện thoại', phone),

              const SizedBox(height: 32),

              _buildSectionTitle('Bạn có thể bắt đầu với'),
              const SizedBox(height: 16),
              _buildTaskItem(Icons.edit_note, 'Ghi chép giao dịch', 'Theo dõi thu chi hàng ngày một cách dễ dàng', Colors.blue.shade50, Colors.blue),
              _buildTaskItem(Icons.pie_chart_outline, 'Xem báo cáo', 'Phân tích thói quen chi tiêu của bạn', Colors.green.shade50, Colors.green),
              _buildTaskItem(Icons.explore_outlined, 'Đặt mục tiêu', 'Lập kế hoạch tài chính và đạt mục tiêu', Colors.orange.shade50, Colors.orange),

              const SizedBox(height: 40),

              // Nút bấm hành động - ĐÃ CẬP NHẬT ĐIỀU HƯỚNG
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  onPressed: () {
                    // 2. Chuyển sang màn hình chọn mục tiêu
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const GoalSelectionScreen()),
                    );
                  },
                  child: const Text('Bắt đầu ngay', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
              TextButton(
                onPressed: () {
                  // Giữ logic thiết lập sau nếu cần thiết
                },
                child: const Text('Thiết lập sau', style: TextStyle(color: Colors.black45)),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      // ... BottomNavigationBar giữ nguyên
    );
  }

  // Các widget _buildSectionTitle, _buildInfoRow, _buildTaskItem giữ nguyên như cũ...
  Widget _buildSectionTitle(String title) => Align(alignment: Alignment.centerLeft, child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)));
  Widget _buildInfoRow(IconData icon, String label, String value) => Padding(padding: const EdgeInsets.symmetric(vertical: 8.0), child: Row(children: [Icon(icon, size: 20, color: Colors.black38), const SizedBox(width: 12), Text(label, style: const TextStyle(color: Colors.black54)), const Spacer(), Text(value, style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.black87))]));
  Widget _buildTaskItem(IconData icon, String title, String sub, Color bgColor, Color iconColor) => Container(margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(12), decoration: BoxDecoration(border: Border.all(color: Colors.black12.withOpacity(0.05)), borderRadius: BorderRadius.circular(12)), child: Row(children: [Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle), child: Icon(icon, color: iconColor)), const SizedBox(width: 16), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)), Text(sub, style: const TextStyle(color: Colors.black38, fontSize: 12))])), const Icon(Icons.chevron_right, color: Colors.black26)]));
}