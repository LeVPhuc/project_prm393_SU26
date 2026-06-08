import 'package:flutter/material.dart';

class BudgetSetupScreen extends StatefulWidget {
  const BudgetSetupScreen({Key? key}) : super(key: key);

  @override
  State<BudgetSetupScreen> createState() => _BudgetSetupScreenState();
}

class _BudgetSetupScreenState extends State<BudgetSetupScreen> {
  // Controller cho các trường ngân sách
  final _foodController = TextEditingController(text: '5.000.000');
  final _transportController = TextEditingController(text: '1.000.000');
  final _shoppingController = TextEditingController(text: '2.000.000');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Thiết lập ngân sách", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Step Indicator
            _buildStepIndicator(),
            const SizedBox(height: 30),

            const Text("Thiết lập hạn mức chi tiêu", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Text("Bạn có thể chỉnh sửa số tiền cho từng danh mục", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 20),

            // Các trường nhập liệu danh mục
            _buildBudgetField("Ăn uống", Icons.restaurant, _foodController),
            _buildBudgetField("Di chuyển", Icons.directions_car, _transportController),
            _buildBudgetField("Mua sắm", Icons.shopping_bag, _shoppingController),

            const SizedBox(height: 40),

            // Tổng kết
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text("Tổng ngân sách", style: TextStyle(fontWeight: FontWeight.bold)),
                  Text("8.000.000 đ", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF00875A), fontSize: 16)),
                ],
              ),
            ),

            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity, height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00875A), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                onPressed: () {
                  // Điều hướng đến Dashboard sau khi hoàn tất
                },
                child: const Text("Hoàn tất", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetField(String label, IconData icon, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFF00875A)),
          suffixText: 'đ',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildStepIndicator() => Row(
    children: [
      _stepItem("Chọn mục tiêu", true),
      _stepItem("Thông tin cơ bản", true),
      _stepItem("Thiết lập ngân sách", true),
    ],
  );

  Widget _stepItem(String title, bool isDone) => Expanded(
    child: Column(children: [
      Icon(isDone ? Icons.check_circle : Icons.circle_outlined, color: isDone ? Colors.green : Colors.grey),
      Text(title, style: TextStyle(fontSize: 10, color: isDone ? Colors.green : Colors.grey)),
    ]),
  );
}