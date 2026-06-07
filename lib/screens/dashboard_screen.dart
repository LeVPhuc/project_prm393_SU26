import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isBalanceVisible = true;
  int _currentIdx = 0;
  bool _showInputForm = false;

  // 1. THÔNG TIN HỒ SƠ GỐC
  String _userName = 'Phúc';

  // 2. TÍNH NĂNG MỚI: HẠN MỨC CHI TIÊU THÁNG
  double _budgetLimit = 20000000;

  // 3. DỮ LIỆU TÀI CHÍNH GỐC ĐẦY ĐỦ
  double _salary = 35400000;
  double _dining = 5200000;
  double _transport = 3500000;
  double _shopping = 3100000;
  double _entertainment = 2400000;
  double _bills = 2300000;
  double _others = 2150000;

  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _budgetCtrl = TextEditingController();
  final TextEditingController _salaryCtrl = TextEditingController();
  final TextEditingController _diningCtrl = TextEditingController();
  final TextEditingController _transportCtrl = TextEditingController();
  final TextEditingController _shoppingCtrl = TextEditingController();
  final TextEditingController _entertainmentCtrl = TextEditingController();
  final TextEditingController _billsCtrl = TextEditingController();
  final TextEditingController _othersCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameCtrl.text = _userName;
    _budgetCtrl.text = _budgetLimit.toStringAsFixed(0);
    _salaryCtrl.text = _salary.toStringAsFixed(0);
    _diningCtrl.text = _dining.toStringAsFixed(0);
    _transportCtrl.text = _transport.toStringAsFixed(0);
    _shoppingCtrl.text = _shopping.toStringAsFixed(0);
    _entertainmentCtrl.text = _entertainment.toStringAsFixed(0);
    _billsCtrl.text = _bills.toStringAsFixed(0);
    _othersCtrl.text = _others.toStringAsFixed(0);
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _budgetCtrl.dispose(); _salaryCtrl.dispose();
    _diningCtrl.dispose(); _transportCtrl.dispose(); _shoppingCtrl.dispose();
    _entertainmentCtrl.dispose(); _billsCtrl.dispose(); _othersCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TÍNH TOÁN SỐ LIỆU ĐỘNG THEO GIAO DIỆN GỐC
    double totalExpense = _dining + _transport + _shopping + _entertainment + _bills + _others;
    double currentBalance = _salary - totalExpense;

    double diningPercent = totalExpense > 0 ? (_dining / totalExpense) * 100 : 0;
    double transportPercent = totalExpense > 0 ? (_transport / totalExpense) * 100 : 0;
    double shoppingPercent = totalExpense > 0 ? (_shopping / totalExpense) * 100 : 0;
    double entertainmentPercent = totalExpense > 0 ? (_entertainment / totalExpense) * 100 : 0;
    double billsPercent = totalExpense > 0 ? (_bills / totalExpense) * 100 : 0;
    double othersPercent = totalExpense > 0 ? (_others / totalExpense) * 100 : 0;

    // LOGIC THANH TIẾN TRÌNH HẠN MỨC
    double percentUsed = _budgetLimit > 0 ? (totalExpense / _budgetLimit) : 0;
    Color progressColor = percentUsed > 1.0
        ? const Color(0xFFEF4444)
        : (percentUsed > 0.8 ? const Color(0xFFF59E0B) : const Color(0xFF10B981));

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),

      // APP BAR GỐC CHI TIẾT
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: const Color(0xFF3B82F6),
              child: Text(
                _userName.isNotEmpty ? _userName.substring(0, 1).toUpperCase() : 'P',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Xin chào, $_userName ', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                    const Text('👋', style: TextStyle(fontSize: 14)),
                  ],
                ),
                const SizedBox(height: 2),
                const Text('Chúc bạn một ngày tốt lành!', style: TextStyle(fontSize: 13, color: Colors.black45, fontWeight: FontWeight.w400)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(_showInputForm ? Icons.assignment_turned_in_outlined : Icons.edit_note_outlined, color: const Color(0xFF3B82F6), size: 28),
            onPressed: () => setState(() => _showInputForm = !_showInputForm),
          ),
          const SizedBox(width: 10),
        ],
      ),

      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // BẢNG CẬP NHẬT DỮ LIỆU ĐẦY ĐỦ KHÔNG BỊ LỖI MÀU
            if (_showInputForm) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.blue.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('⚙️ CẬP NHẬT HỒ SƠ & SỐ LIỆU', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A), fontSize: 14)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _buildInputField(_nameCtrl, 'Tên hiển thị', isNumber: false)),
                        const SizedBox(width: 10),
                        Expanded(child: _buildInputField(_budgetCtrl, 'Hạn mức chi tiêu')),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(child: _buildInputField(_salaryCtrl, 'Thu nhập (Lương)')),
                        const SizedBox(width: 10),
                        Expanded(child: _buildInputField(_diningCtrl, 'Tiền Ăn uống')),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(child: _buildInputField(_transportCtrl, 'Tiền Đi lại')),
                        const SizedBox(width: 10),
                        Expanded(child: _buildInputField(_shoppingCtrl, 'Tiền Mua sắm')),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(child: _buildInputField(_entertainmentCtrl, 'Tiền Giải trí')),
                        const SizedBox(width: 10),
                        Expanded(child: _buildInputField(_billsCtrl, 'Tiền Hóa đơn')),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _buildInputField(_othersCtrl, 'Các chi phí Khác'),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _userName = _nameCtrl.text.trim().isNotEmpty ? _nameCtrl.text.trim() : 'Phúc';
                            _budgetLimit = double.tryParse(_budgetCtrl.text) ?? 0;
                            _salary = double.tryParse(_salaryCtrl.text) ?? 0;
                            _dining = double.tryParse(_diningCtrl.text) ?? 0;
                            _transport = double.tryParse(_transportCtrl.text) ?? 0;
                            _shopping = double.tryParse(_shoppingCtrl.text) ?? 0;
                            _entertainment = double.tryParse(_entertainmentCtrl.text) ?? 0;
                            _bills = double.tryParse(_billsCtrl.text) ?? 0;
                            _others = double.tryParse(_othersCtrl.text) ?? 0;
                            _showInputForm = false;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3B82F6),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: const Icon(Icons.sync, color: Colors.white, size: 20),
                        label: const Text('Cập nhật dữ liệu hệ thống', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // GIAO DIỆN GỐC 1: THẺ SỐ DƯ TỔNG GRADIENT CHUẨN
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4F46E5), Color(0xFF3B82F6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.15), blurRadius: 10, offset: const Offset(0, 5))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('Tổng số dư', style: TextStyle(color: Colors.white70, fontSize: 14)),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => setState(() => _isBalanceVisible = !_isBalanceVisible),
                        child: Icon(_isBalanceVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: Colors.white70, size: 18),
                      )
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isBalanceVisible ? '${_formatMoney(currentBalance)} đ' : '•••••••• đ',
                    style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 12),
                  const Text('Tài khoản', style: TextStyle(color: Colors.white60, fontSize: 12)),
                  const SizedBox(height: 4),
                  Row(
                    children: const [
                      Text('Ví chính', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                      Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 16),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // GIAO DIỆN GỐC 2: THẺ TỔNG QUAN THU NHẬP VÀ CHI TIÊU THÁNG ĐỘNG
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)]),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.calendar_today_outlined, size: 16, color: Color(0xFF3B82F6)),
                          SizedBox(width: 6),
                          Text('Tổng quan tháng 5', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87)),
                        ],
                      ),
                      const Text('Xem chi tiết >', style: TextStyle(color: Color(0xFF3B82F6), fontSize: 12)),
                    ],
                  ),
                  const Divider(height: 20, thickness: 0.5),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Thu nhập', style: TextStyle(color: Colors.black45, fontSize: 12)),
                            const SizedBox(height: 4),
                            Text('${_formatMoney(_salary)} đ', style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 4),
                            Row(children: const [Icon(Icons.arrow_upward, color: Colors.black38, size: 12), Text(' 12.5% so với tháng 4', style: TextStyle(color: Colors.black38, fontSize: 11))]),
                          ],
                        ),
                      ),
                      Container(height: 40, width: 0.5, color: Colors.black12),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Chi tiêu', style: TextStyle(color: Colors.black45, fontSize: 12)),
                            const SizedBox(height: 4),
                            Text('${_formatMoney(totalExpense)} đ', style: const TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 4),
                            Row(children: const [Icon(Icons.arrow_downward, color: Colors.black38, size: 12), Text(' 8.3% so với tháng 4', style: TextStyle(color: Colors.black38, fontSize: 11))]),
                          ],
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 24),

            // TÍNH NĂNG MỚI ĐƯỢC CHÈN THÊM VÀO GIỮA: HẠN MỨC CHI TIÊU CHUẨN CÚ PHÁP
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Hạn mức chi tiêu', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                Text('${(percentUsed * 100).toStringAsFixed(1)}%', style: TextStyle(color: progressColor, fontWeight: FontWeight.bold, fontSize: 13)),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)]),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Đã chi: ${_formatMoney(totalExpense)} đ', style: const TextStyle(fontSize: 12, color: Colors.black54)),
                      Text('Hạn mức: ${_formatMoney(_budgetLimit)} đ', style: const TextStyle(fontSize: 12, color: Colors.black54)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: percentUsed > 1.0 ? 1.0 : percentUsed,
                      minHeight: 10,
                      backgroundColor: Colors.grey.shade100,
                      valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                    ),
                  ),
                  if (percentUsed > 1.0)
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0), // SỬA: Dùng EdgeInsets.only đúng chuẩn
                      child: Row(
                        children: [
                          const Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444), size: 16),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Chú ý: Bạn đã chi vượt mức cho phép ${_formatMoney(totalExpense - _budgetLimit)} đ!',
                              style: const TextStyle(color: Color(0xFFEF4444), fontSize: 11, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // GIAO DIỆN GỐC 3: BIỂU ĐỒ TRÒN PHÂN BỔ CHI TIÊU ĐẦY ĐỦ 6 DANH MỤC
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Phân bổ chi tiêu', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                const Text('Xem chi tiết >', style: TextStyle(color: Color(0xFF3B82F6), fontSize: 12)),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)]),
              child: Row(
                children: [
                  SizedBox(
                    width: 110,
                    height: 110,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 30,
                        sections: totalExpense == 0
                            ? [PieChartSectionData(color: Colors.grey.shade300, value: 100, radius: 12, showTitle: false)]
                            : [
                          PieChartSectionData(color: const Color(0xFF3B82F6), value: _dining, radius: 12, showTitle: false),
                          PieChartSectionData(color: const Color(0xFF10B981), value: _transport, radius: 12, showTitle: false),
                          PieChartSectionData(color: const Color(0xFFF59E0B), value: _shopping, radius: 12, showTitle: false),
                          PieChartSectionData(color: const Color(0xFF8B5CF6), value: _entertainment, radius: 12, showTitle: false),
                          PieChartSectionData(color: const Color(0xFFEF4444), value: _bills, radius: 12, showTitle: false),
                          PieChartSectionData(color: const Color(0xFF64748B), value: _others, radius: 12, showTitle: false),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildChartLegend(const Color(0xFF3B82F6), 'Ăn uống', _formatMoney(_dining), '${diningPercent.toStringAsFixed(1)}%'),
                        _buildChartLegend(const Color(0xFF10B981), 'Đi lại', _formatMoney(_transport), '${transportPercent.toStringAsFixed(1)}%'),
                        _buildChartLegend(const Color(0xFFF59E0B), 'Mua sắm', _formatMoney(_shopping), '${shoppingPercent.toStringAsFixed(1)}%'),
                        _buildChartLegend(const Color(0xFF8B5CF6), 'Giải trí', _formatMoney(_entertainment), '${entertainmentPercent.toStringAsFixed(1)}%'),
                        _buildChartLegend(const Color(0xFFEF4444), 'Hóa đơn', _formatMoney(_bills), '${billsPercent.toStringAsFixed(1)}%'),
                        _buildChartLegend(const Color(0xFF64748B), 'Khác', _formatMoney(_others), '${othersPercent.toStringAsFixed(1)}%'),
                      ],
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 24),

            // GIAO DIỆN GỐC 4: DANH SÁCH LỊCH SỬ GIAO DỊCH GẦN ĐÂY ĐẦY ĐỦ VỚI MÀU SẮC CHUẨN
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Giao dịch gần đây', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                const Text('Xem tất cả >', style: TextStyle(color: Color(0xFF3B82F6), fontSize: 12)),
              ],
            ),
            const SizedBox(height: 10),
            _buildTransactionItem('Lương nhận tháng này', 'Thu nhập', '20/05/2026', '+${_formatMoney(_salary)} đ', const Color(0xFF10B981), Icons.arrow_downward, const Color(0xFFE8F5E9)),
            _buildTransactionItem('Chi phí ăn uống sinh hoạt', 'Chi tiêu', '20/05/2026', '-${_formatMoney(_dining)} đ', const Color(0xFFEF4444), Icons.restaurant, const Color(0xFFFFF3E0)),
            _buildTransactionItem('Mua sắm vật dụng cá nhân', 'Chi tiêu', '19/05/2026', '-${_formatMoney(_shopping)} đ', const Color(0xFFEF4444), Icons.shopping_cart, const Color(0xFFE3F2FD)),
            _buildTransactionItem('Thanh toán hóa đơn điện nước', 'Chi tiêu', '19/05/2026', '-${_formatMoney(_bills)} đ', const Color(0xFFEF4444), Icons.receipt_long, const Color(0xFFF3E5F5)),
            const SizedBox(height: 20),
          ],
        ),
      ),

      // BOTTOM NAVIGATION BAR GỐC CÓ ĐỤNG LỖ ĐẸP MẮT
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 6.0,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildBottomNavItem(Icons.home_filled, 'Trang chủ', 0),
              _buildBottomNavItem(Icons.assignment_outlined, 'Giao dịch', 1),
              const SizedBox(width: 40),
              _buildBottomNavItem(Icons.bar_chart_outlined, 'Báo cáo', 2),
              _buildBottomNavItem(Icons.person_outline, 'Khác', 3),
            ],
          ),
        ),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () => setState(() => _showInputForm = !_showInputForm),
        backgroundColor: const Color(0xFF3B82F6),
        shape: const CircleBorder(),
        elevation: 3,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildInputField(TextEditingController controller, String label, {bool isNumber = true}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 12, color: Colors.black45),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
      ),
    );
  }

  String _formatMoney(double value) {
    RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return value.toStringAsFixed(0).replaceAllMapped(reg, (Match match) => '${match[1]}.');
  }

  Widget _buildChartLegend(Color color, String category, String price, String percent) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        children: [
          Container(width: 10, height: 10, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
          const SizedBox(width: 8),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(category, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black87)),
                Text('$price đ', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(percent, style: const TextStyle(fontSize: 11, color: Colors.black38)),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(String title, String type, String date, String amount, Color amountColor, IconData icon, Color iconBg) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(backgroundColor: iconBg, radius: 18, child: Icon(icon, color: amountColor, size: 18)),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
                  const SizedBox(height: 2),
                  Text(type, style: const TextStyle(color: Colors.black38, fontSize: 11)),
                ],
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(amount, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: amountColor)),
              const SizedBox(height: 2),
              Text(date, style: const TextStyle(color: Colors.black38, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavItem(IconData icon, String label, int index) {
    bool isActive = _currentIdx == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIdx = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: isActive ? const Color(0xFF3B82F6) : Colors.black38, size: 24),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(color: isActive ? const Color(0xFF3B82F6) : Colors.black38, fontSize: 10, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}