import 'package:flutter/material.dart';

class TransactionScreen extends StatelessWidget {
  final String userName;
  const TransactionScreen({Key? key, required this.userName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Scaffold ở đây chỉ chứa AppBar và Body.
    // Navigation bar và FAB đã nằm ở MainWrapper.
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text("Giao dịch", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
        centerTitle: true,
        // Nút quay lại điều hướng về trang trước
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildDateSection("Hôm nay"),
                _buildTransactionItem("Siêu thị Coopmart", "Ăn uống", "-450.000 đ", Colors.redAccent),
                _buildTransactionItem("Lương tháng 5", "Thu nhập", "+20.000.000 đ", Colors.green),
                _buildDateSection("Hôm qua"),
                _buildTransactionItem("Highlands Coffee", "Ăn uống", "-65.000 đ", Colors.redAccent),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    color: const Color(0xFF1E1E1E),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: ["Tất cả", "Thu nhập", "Chi tiêu"].map((f) => Chip(
        label: Text(f, style: const TextStyle(color: Colors.white, fontSize: 12)),
        backgroundColor: Colors.white10,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      )).toList(),
    ),
  );

  Widget _buildDateSection(String date) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Text(date, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 13)),
  );

  Widget _buildTransactionItem(String title, String category, String amount, Color color) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(16)),
    child: ListTile(
      leading: const CircleAvatar(backgroundColor: Colors.white10, child: Icon(Icons.receipt, color: Colors.white)),
      title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      subtitle: Text(category, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      trailing: Text(amount, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
    ),
  );
}