import 'package:flutter/material.dart';
import 'basic_info_setup_screen.dart'; // Đảm bảo bạn đã import file này

class GoalSelectionScreen extends StatefulWidget {
  const GoalSelectionScreen({Key? key}) : super(key: key);

  @override
  State<GoalSelectionScreen> createState() => _GoalSelectionScreenState();
}

class _GoalSelectionScreenState extends State<GoalSelectionScreen> {
  int _selectedGoal = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white, elevation: 0, iconTheme: const IconThemeData(color: Colors.black)),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thanh tiến trình (Cập nhật màu sắc)
            Row(children: List.generate(4, (i) => Expanded(child: Icon(i == 0 ? Icons.check_circle : Icons.circle_outlined, size: 12, color: i == 0 ? const Color(0xFF00875A) : Colors.grey)))),
            const SizedBox(height: 20),
            const Text("Bạn muốn tập trung vào mục tiêu nào?", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const Text("Chọn mục tiêu phù hợp để Vun Vén đồng hành cùng bạn.", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 20),

            // Danh sách mục tiêu (Đã thêm đầy đủ theo ảnh)
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildGoalOption(0, "Tiết kiệm", "Tạo kế hoạch tiết kiệm và theo dõi để đạt mục tiêu của bạn.", Icons.track_changes),
                    _buildGoalOption(1, "Kiểm soát chi tiêu", "Quản lý chi tiêu hàng ngày, phân tích thói quen và tối ưu ngân sách.", Icons.account_balance_wallet_outlined),
                    _buildGoalOption(2, "Tăng thu nhập", "Theo dõi nguồn thu và tìm cách gia tăng thu nhập.", Icons.trending_up),
                    _buildGoalOption(3, "Tự do tài chính", "Lập kế hoạch dài hạn để đạt độc lập tài chính.", Icons.landscape_outlined),
                    _buildGoalOption(4, "Khác", "Tùy chỉnh mục tiêu theo nhu cầu của bạn.", Icons.more_horiz),
                  ],
                ),
              ),
            ),

            // Box bảo mật
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(12)),
              child: const Row(children: [Icon(Icons.lock_outline, color: Color(0xFF00875A)), SizedBox(width: 10), Expanded(child: Text("Dữ liệu của bạn luôn được bảo mật và an toàn.", style: TextStyle(fontSize: 12)))]),
            ),

            // Nút Tiếp tục
            SizedBox(
              width: double.infinity, height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00875A), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                onPressed: () {
                  // Chuyển hướng sang màn hình tiếp theo
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const BasicInfoSetupScreen()),
                  );
                },
                child: const Text("Tiếp tục", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildGoalOption(int index, String title, String sub, IconData icon) {
    bool isSelected = _selectedGoal == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedGoal = index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          border: Border.all(color: isSelected ? const Color(0xFF00875A) : Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF00875A)),
            const SizedBox(width: 15),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.bold)), Text(sub, style: TextStyle(fontSize: 12, color: Colors.grey.shade600))])),
            if (isSelected) const Icon(Icons.check_circle, color: Color(0xFF00875A))
          ],
        ),
      ),
    );
  }
}