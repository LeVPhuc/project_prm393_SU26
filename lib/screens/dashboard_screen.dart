import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class DashboardScreen extends StatelessWidget {
  final String userName;

  const DashboardScreen({Key? key, required this.userName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Scaffold ở đây chỉ chứa body, không cần BottomNavigationBar hay FAB
    // vì chúng đã nằm ở MainWrapper
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildHeader(),
          const SizedBox(height: 20),
          _buildMainBalanceCard(),
          const SizedBox(height: 16),
          _buildStatsRow(),
          const SizedBox(height: 16),
          _buildChartSection(),
          const SizedBox(height: 16),
          _buildQuickActions(),
          const SizedBox(height: 20),
          _buildTransactionList(),
          const SizedBox(height: 20), // Khoảng đệm cuối màn hình
        ],
      ),
    );
  }

  Widget _buildHeader() => Row(
    children: [
      const CircleAvatar(radius: 22, backgroundColor: Color(0xFF00875A), child: Icon(Icons.person, color: Colors.white)),
      const SizedBox(width: 12),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text("Xin chào, $userName 👋", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        const Text("Quản lý tài chính, làm chủ cuộc sống", style: TextStyle(color: Colors.grey, fontSize: 12)),
      ]),
      const Spacer(),
      const Icon(Icons.notifications_none, color: Colors.white),
    ],
  );

  Widget _buildMainBalanceCard() => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(color: const Color(0xFF00875A), borderRadius: BorderRadius.circular(24)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
      Text("Tổng số dư", style: TextStyle(color: Colors.white70)),
      SizedBox(height: 8),
      Text("25.000.000 đ", style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
      Text("Cập nhật: Hôm nay, 09:41", style: TextStyle(color: Colors.white60, fontSize: 10)),
    ]),
  );

  Widget _buildStatsRow() => Row(
    children: [
      _statItem("Thu nhập", "20.000.000 đ", Colors.green),
      _statItem("Chi tiêu", "8.200.000 đ", Colors.redAccent),
      _statItem("Còn lại", "11.800.000 đ", Colors.blue),
    ],
  );

  Widget _statItem(String title, String val, Color color) => Expanded(
    child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(16)),
      child: Column(children: [
        Text(title, style: const TextStyle(color: Colors.grey, fontSize: 10)),
        const SizedBox(height: 5),
        Text(val, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11)),
      ]),
    ),
  );

  Widget _buildChartSection() => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(20)),
    child: Row(children: [
      SizedBox(width: 90, height: 90, child: PieChart(PieChartData(sections: [
        PieChartSectionData(value: 40, color: Colors.green, title: '', radius: 15),
        PieChartSectionData(value: 30, color: Colors.blue, title: '', radius: 15),
        PieChartSectionData(value: 30, color: Colors.orange, title: '', radius: 15),
      ]))),
      const SizedBox(width: 20),
      const Expanded(child: Text("Biểu đồ phân bổ chi tiêu tháng 5/2024", style: TextStyle(color: Colors.white, fontSize: 13))),
    ]),
  );

  Widget _buildQuickActions() => Row(
    mainAxisAlignment: MainAxisAlignment.spaceAround,
    children: [
      _actionButton(Icons.add, "Thu nhập"),
      _actionButton(Icons.edit, "Chi tiêu"),
      _actionButton(Icons.swap_horiz, "Chuyển khoản"),
    ],
  );

  Widget _actionButton(IconData icon, String label) => Column(children: [
    Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(16)), child: Icon(icon, color: Colors.white)),
    const SizedBox(height: 8),
    Text(label, style: const TextStyle(color: Colors.white, fontSize: 10)),
  ]);

  Widget _buildTransactionList() => Container(
    padding: const EdgeInsets.symmetric(vertical: 10),
    decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(20)),
    child: Column(children: const [
      ListTile(title: Text("Siêu thị Coopmart", style: TextStyle(color: Colors.white)), subtitle: Text("Ăn uống", style: TextStyle(color: Colors.grey)), trailing: Text("-450.000 đ", style: TextStyle(color: Colors.redAccent))),
      ListTile(title: Text("Lương tháng 5", style: TextStyle(color: Colors.white)), subtitle: Text("Thu nhập", style: TextStyle(color: Colors.grey)), trailing: Text("+20.000.000 đ", style: TextStyle(color: Colors.green))),
    ]),
  );
}