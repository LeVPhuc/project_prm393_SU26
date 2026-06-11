import 'package:flutter/material.dart';
import 'budget_setup_screen.dart'; // Import màn hình Thiết lập ngân sách

class BasicInfoSetupScreen extends StatefulWidget {
  const BasicInfoSetupScreen({Key? key}) : super(key: key);

  @override
  State<BasicInfoSetupScreen> createState() => _BasicInfoSetupScreenState();
}

class _BasicInfoSetupScreenState extends State<BasicInfoSetupScreen> {
  String? _selectedJob;
  String? _selectedIncome;
  String? _financialStatus = 'Tốt';

  final List<String> _jobs = ['Nhân viên văn phòng', 'Kinh doanh', 'Sinh viên', 'Khác'];
  final List<String> _incomes = ['Dưới 10 triệu', '10 - 20 triệu', 'Trên 20 triệu'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Thiết lập thông tin cơ bản", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStepIndicator(),
            const SizedBox(height: 30),

            _buildLabel("Họ và tên"),
            _buildTextField("Nguyễn Văn A", Icons.person_outline),
            _buildLabel("Ngày sinh"),
            _buildTextField("15/05/1995", Icons.calendar_today),
            _buildLabel("Email"),
            _buildTextField("admin@vunven.com", Icons.email_outlined),

            _buildLabel("Nghề nghiệp"),
            DropdownButtonFormField<String>(
              value: _selectedJob, hint: const Text("Chọn nghề nghiệp"),
              items: _jobs.map((job) => DropdownMenuItem(value: job, child: Text(job))).toList(),
              onChanged: (val) => setState(() => _selectedJob = val),
              decoration: _inputDecoration(Icons.work_outline),
            ),

            _buildLabel("Thu nhập trung bình hàng tháng"),
            DropdownButtonFormField<String>(
              value: _selectedIncome, hint: const Text("Chọn mức thu nhập"),
              items: _incomes.map((inc) => DropdownMenuItem(value: inc, child: Text(inc))).toList(),
              onChanged: (val) => setState(() => _selectedIncome = val),
              decoration: _inputDecoration(Icons.attach_money),
            ),

            const SizedBox(height: 25),
            const Text("Tình trạng tài chính hiện tại của bạn như thế nào?", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),

            // Grid 4 trạng thái tài chính
            GridView.count(
              shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2, mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 1.5,
              children: [
                _buildStatusOption("Tốt", Icons.sentiment_very_satisfied, Colors.green),
                _buildStatusOption("Bình thường", Icons.sentiment_neutral, Colors.orange),
                _buildStatusOption("Khó khăn", Icons.sentiment_dissatisfied, Colors.redAccent),
                _buildStatusOption("Rất khó khăn", Icons.sentiment_very_dissatisfied, Colors.grey),
              ],
            ),

            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(12)),
              child: const Row(children: [Icon(Icons.lock_outline, color: Colors.green), SizedBox(width: 10), Expanded(child: Text("Thông tin của bạn được bảo mật tuyệt đối", style: TextStyle(fontSize: 12)))]),
            ),

            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity, height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00875A), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                onPressed: () {
                  // Chuyển hướng sang màn hình thiết lập ngân sách
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const BudgetSetupScreen(userName: "Le Van Phuc")));
                },
                child: const Text("Tiếp tục", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }

  // --- Widgets Hỗ trợ ---
  Widget _buildLabel(String text) => Padding(padding: const EdgeInsets.only(bottom: 8, top: 10), child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)));
  InputDecoration _inputDecoration(IconData icon) => InputDecoration(prefixIcon: Icon(icon, color: Colors.grey), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), contentPadding: const EdgeInsets.symmetric(vertical: 16));
  Widget _buildTextField(String hint, IconData icon) => TextField(decoration: _inputDecoration(icon).copyWith(hintText: hint));

  Widget _buildStatusOption(String label, IconData icon, Color color) {
    bool isSelected = _financialStatus == label;
    return GestureDetector(
      onTap: () => setState(() => _financialStatus = label),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.white,
          border: Border.all(color: isSelected ? color : Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, color: color), const SizedBox(height: 5), Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12))]),
      ),
    );
  }

  Widget _buildStepIndicator() => Row(
    children: [
      _stepItem("Chọn mục tiêu", true),
      _stepItem("Thông tin cơ bản", true),
      _stepItem("Thiết lập ngân sách", false),
    ],
  );

  Widget _stepItem(String title, bool isDone) => Expanded(
    child: Column(children: [
      Icon(isDone ? Icons.check_circle : Icons.circle_outlined, color: isDone ? Colors.green : Colors.grey),
      Text(title, style: TextStyle(fontSize: 10, color: isDone ? Colors.green : Colors.grey)),
    ]),
  );
}