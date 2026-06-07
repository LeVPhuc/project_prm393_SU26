import 'package:flutter/material.dart';

class TransactionHistoryScreen extends StatelessWidget {
  const TransactionHistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2FBF7),
      appBar: AppBar(
        title: const Text('Lịch Sử Giao Dịch', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF10B981),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Tháng này', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
          const SizedBox(height: 10),
          _buildHistoryItem('Tiền lương tháng này', '05/06/2026', '+8,500,000 đ', Colors.green),
          _buildHistoryItem('Mua cà phê làm việc', '04/06/2026', '-45,000 đ', Colors.red),
          _buildHistoryItem('Cơm trưa văn phòng', '03/06/2026', '-60,000 đ', Colors.red),
          _buildHistoryItem('Mua sách Vun Vén tài chính', '01/06/2026', '-120,000 đ', Colors.red),
          const SizedBox(height: 20),
          const Text('Tháng trước', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
          const SizedBox(height: 10),
          _buildHistoryItem('Thưởng dự án SU26', '25/05/2026', '+2,000,000 đ', Colors.green),
          _buildHistoryItem('Thanh toán tiền điện', '20/05/2026', '-1,200,000 đ', Colors.red),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(String title, String date, String amount, Color amountColor) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 5),
              Text(date, style: const TextStyle(color: Colors.black38, fontSize: 13)),
            ],
          ),
          Text(amount, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: amountColor)),
        ],
      ),
    );
  }
}