import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

// ==========================================================================
// 1. BỘ ĐỊNH DẠNG TIỀN TỆ ĐỘNG - SỬA LỖI NHẢY CON TRỎ CHUỘT KHI NHẬP SỐ
// ==========================================================================
class MoneyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue.copyWith(text: '');

    // Chỉ giữ lại các chữ số
    String cleanText = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    if (cleanText.isEmpty) return newValue.copyWith(text: '');

    double value = double.parse(cleanText);
    final RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    String formattedText = value.toStringAsFixed(0).replaceAllMapped(reg, (Match match) => '${match[1]}.');

    // Tính toán lại vị trí con trỏ chính xác sau khi chèn các dấu chấm phân cách
    int cursorOffset = newValue.selection.end;
    int oldDotCount = oldValue.text.substring(0, math.min(oldValue.selection.end, oldValue.text.length)).split('.').length - 1;
    int newDotCount = formattedText.substring(0, math.min(cursorOffset, formattedText.length)).split('.').length - 1;
    int finalOffset = cursorOffset + (newDotCount - oldDotCount);
    finalOffset = math.max(0, math.min(finalOffset, formattedText.length));

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: finalOffset),
    );
  }
}

// ==========================================================================
// 2. MÀN HÌNH DASHBOARD CHÍNH
// ==========================================================================
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isBalanceVisible = true;

  // Dữ liệu quản lý tài chính thực tế ban đầu
  String _userName = 'Minh';
  double _budgetLimit = 20000000;
  double _salary = 35400000;
  double _dining = 5200000;
  double _transport = 3500000;
  double _shopping = 3100000;
  double _entertainment = 2400000;
  double _bills = 2300000;
  double _others = 2150000;

  // Các bộ điều khiển dữ liệu form nhập liệu
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
    _syncDataToControllers();
  }

  // Đồng bộ dữ liệu hiện tại lên các ô Input trong Form
  void _syncDataToControllers() {
    _nameCtrl.text = _userName;
    _budgetCtrl.text = _formatMoney(_budgetLimit);
    _salaryCtrl.text = _formatMoney(_salary); // Thu nhập đã được đồng bộ chuẩn xác
    _diningCtrl.text = _formatMoney(_dining);
    _transportCtrl.text = _formatMoney(_transport);
    _shoppingCtrl.text = _formatMoney(_shopping);
    _entertainmentCtrl.text = _formatMoney(_entertainment);
    _billsCtrl.text = _formatMoney(_bills);
    _othersCtrl.text = _formatMoney(_others);
  }

  String _formatMoney(double value) {
    RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return value.toStringAsFixed(0).replaceAllMapped(reg, (Match match) => '${match[1]}.');
  }

  double _parseMoney(String text) {
    return double.tryParse(text.replaceAll('.', '')) ?? 0;
  }

  // Hàm mở Bottom Sheet chứa Form sửa đổi khi bấm nút Dấu cộng (+)
  void _openEditBottomSheet() {
    _syncDataToControllers();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              // ĐÃ SỬA: Sử dụng BoxConstraints để giới hạn chiều cao tối đa, tránh lỗi crash compile
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.85,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
              ),
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20, // Tự động đẩy lên khi bàn phím ảo xuất hiện
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Row(
                      children: [
                        Icon(Icons.tune_rounded, color: Color(0xFF2F66F6), size: 22),
                        SizedBox(width: 8),
                        Text(
                          'Cập Nhật Hồ Sơ & Số Liệu',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B), fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildInputField(_nameCtrl, 'Tên hiển thị', isNumber: false),
                    _buildInputField(_budgetCtrl, 'Hạn mức chi tiêu'),
                    _buildInputField(_salaryCtrl, 'Thu nhập (Lương)'), // Ô nhập thu nhập mở khóa gõ bình thường
                    _buildInputField(_diningCtrl, 'Tiền Ăn uống'),
                    _buildInputField(_transportCtrl, 'Tiền Đi lại'),
                    _buildInputField(_shoppingCtrl, 'Tiền Mua sắm'),
                    _buildInputField(_entertainmentCtrl, 'Tiền Giải trí'),
                    _buildInputField(_billsCtrl, 'Tiền Hóa đơn'),
                    _buildInputField(_othersCtrl, 'Các chi phí Khác'),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setModalState(() {
                                _diningCtrl.text = "0";
                                _transportCtrl.text = "0";
                                _shoppingCtrl.text = "0";
                                _entertainmentCtrl.text = "0";
                                _billsCtrl.text = "0";
                                _othersCtrl.text = "0";
                              });
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.redAccent),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Xóa chi tiêu', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _userName = _nameCtrl.text;
                                _budgetLimit = _parseMoney(_budgetCtrl.text);
                                _salary = _parseMoney(_salaryCtrl.text);
                                _dining = _parseMoney(_diningCtrl.text);
                                _transport = _parseMoney(_transportCtrl.text);
                                _shopping = _parseMoney(_shoppingCtrl.text);
                                _entertainment = _parseMoney(_entertainmentCtrl.text);
                                _bills = _parseMoney(_billsCtrl.text);
                                _others = _parseMoney(_othersCtrl.text);
                              });
                              Navigator.pop(context); // Lưu thành công và đóng Bottom Sheet
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2F66F6),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Cập nhật hệ thống', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildInputField(TextEditingController controller, String label, {bool isNumber = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
        inputFormatters: isNumber ? [FilteringTextInputFormatter.digitsOnly, MoneyInputFormatter()] : null,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF2F66F6), width: 1.5)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double totalExpense = _dining + _transport + _shopping + _entertainment + _bills + _others;
    double currentBalance = _salary - totalExpense;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPremiumBalanceCard(currentBalance),
            const SizedBox(height: 16),
            _buildMonthlyOverviewWidget(_salary, totalExpense),
            const SizedBox(height: 20),
            _buildSectionTitleRow('Phân bổ chi tiêu', 'Xem chi tiết >'),
            const SizedBox(height: 12),
            _buildPieChartDistributionSection(totalExpense),
            const SizedBox(height: 20),
            _buildSectionTitleRow('Giao dịch gần đây', 'Xem tất cả >'),
            const SizedBox(height: 12),
            _buildRecentTransactionsCard(),
          ],
        ),
      ),
      // CẤU TRÚC BOTTOM NAV BAR NỔI BẬT NÚT DẤU CỘNG (+) CHÍNH GIỮA
      bottomNavigationBar: Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none,
        children: [
          BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: const Color(0xFF2F66F6),
            unselectedItemColor: const Color(0xFF94A3B8),
            selectedFontSize: 11,
            unselectedFontSize: 11,
            currentIndex: 0,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home_filled, size: 22), label: 'Trang chủ'),
              BottomNavigationBarItem(icon: Icon(Icons.assignment_outlined, size: 22), label: 'Giao dịch'),
              BottomNavigationBarItem(icon: SizedBox(width: 40), label: 'Thêm'), // Giữ khoảng trống cho nút (+)
              BottomNavigationBarItem(icon: Icon(Icons.bar_chart_outlined, size: 22), label: 'Báo cáo'),
              BottomNavigationBarItem(icon: Icon(Icons.person_outline, size: 22), label: 'Khác'),
            ],
          ),
          Positioned(
            top: -15, // Tạo hiệu ứng lồi nút bấm 3D lên trên thanh bar
            child: GestureDetector(
              onTap: _openEditBottomSheet, // Gọi sự kiện mở form
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF4A77FF), Color(0xFF2251FF)]),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: const Color(0xFF2555FF).withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))
                  ],
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 28),
              ),
            ),
          )
        ],
      ),
    );
  }

  // ==========================================================================
  // 3. CÁC THÀNH PHẦN GIAO DIỆN PHỤ TRỢ (MÀU SẮC, KIỂU CHỮ GỐC)
  // ==========================================================================
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: const Color(0xFFE2E8F0),
            child: Text(_userName.isNotEmpty ? _userName[0].toUpperCase() : 'M', style: const TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Xin chào, $_userName 👋', style: const TextStyle(color: Color(0xFF1E293B), fontSize: 15, fontWeight: FontWeight.bold)),
              const Text('Chúc bạn một ngày tốt lành!', style: TextStyle(color: Color(0xFF64748B), fontSize: 11)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildPremiumBalanceCard(double balance) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF4A77FF), Color(0xFF2251FF)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('Tổng số dư', style: TextStyle(color: Color(0xFFCECECE), fontSize: 12)),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => setState(() => _isBalanceVisible = !_isBalanceVisible),
                    child: Icon(_isBalanceVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: const Color(0xFFBDBDBD), size: 16),
                  )
                ],
              ),
              const SizedBox(height: 8),
              Text(_isBalanceVisible ? '${_formatMoney(balance)} đ' : '•••••••• đ', style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Ví chính', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                  Icon(Icons.arrow_drop_down, color: Colors.white, size: 18),
                ],
              )
            ],
          ),
          const Positioned(
            right: 0, top: 12,
            child: CircleAvatar(radius: 24, backgroundColor: Colors.white12, child: Icon(Icons.account_balance_wallet_rounded, size: 26, color: Colors.white)),
          )
        ],
      ),
    );
  }

  Widget _buildMonthlyOverviewWidget(double income, double expense) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: Color(0xFFF1F5F9))),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Thu nhập', style: TextStyle(color: Color(0xFF64748B), fontSize: 11)),
                  const SizedBox(height: 6),
                  Text('${_formatMoney(income)} đ', style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 15)),
                ],
              ),
            ),
            Container(width: 1, height: 35, color: const Color(0xFFE2E8F0)),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Chi tiêu', style: TextStyle(color: Color(0xFF64748B), fontSize: 11)),
                    const SizedBox(height: 6),
                    Text('${_formatMoney(expense)} đ', style: const TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.bold, fontSize: 15)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChartDistributionSection(double total) {
    double pDining = total > 0 ? (_dining / total) * 100 : 0;
    double pTransport = total > 0 ? (_transport / total) * 100 : 0;
    double pShopping = total > 0 ? (_shopping / total) * 100 : 0;

    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: Color(0xFFF1F5F9))),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 100, height: 100,
                  child: CustomPaint(painter: BudgetPiePainter(d: _dining, t: _transport, s: _shopping, e: _entertainment, b: _bills, o: _others)),
                ),
                Text('${_formatMoney(total)} đ', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                children: [
                  _buildPieRow('Ăn uống', pDining, const Color(0xFF3B82F6)),
                  _buildPieRow('Đi lại', pTransport, const Color(0xFF10B981)),
                  _buildPieRow('Mua sắm', pShopping, const Color(0xFFF59E0B)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildPieRow(String label, double pct, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(children: [CircleAvatar(radius: 4, backgroundColor: color), const SizedBox(width: 6), Text(label, style: const TextStyle(fontSize: 11))]),
          Text('${pct.toStringAsFixed(1)}%', style: const TextStyle(fontSize: 11, color: Colors.grey), textAlign: TextAlign.right),
        ],
      ),
    );
  }

  Widget _buildRecentTransactionsCard() {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: Color(0xFFF1F5F9))),
      child: ListTile(
        dense: true,
        leading: const CircleAvatar(backgroundColor: Color(0xFFEFF6FF), child: Icon(Icons.restaurant, size: 16, color: Colors.blue)),
        title: const Text('Ăn trưa', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        subtitle: const Text('Chi tiêu • Hôm nay', style: TextStyle(fontSize: 10)),
        trailing: Text('-${_formatMoney(_dining)} đ', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.red)),
      ),
    );
  }

  Widget _buildSectionTitleRow(String title, String actionText) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        Text(actionText, style: const TextStyle(color: Colors.blue, fontSize: 11)),
      ],
    );
  }
}

// ==========================================================================
// 4. LỚP VẼ CUSTOM PAINT CHO BIỂU ĐỒ TRÒN RỖNG (6 DANH MỤC CHI TIÊU)
// ==========================================================================
class BudgetPiePainter extends CustomPainter {
  final double d, t, s, e, b, o;
  BudgetPiePainter({required this.d, required this.t, required this.s, required this.e, required this.b, required this.o});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final strokePaint = Paint()..style = PaintingStyle.stroke..strokeWidth = 12..strokeCap = StrokeCap.round;

    double total = d + t + s + e + b + o;
    if (total == 0) {
      canvas.drawArc(rect, 0, 2 * math.pi, false, strokePaint..color = const Color(0xFFE2E8F0));
      return;
    }

    double startAngle = -math.pi / 2;
    final categories = [
      {'val': d, 'color': const Color(0xFF3B82F6)},
      {'val': t, 'color': const Color(0xFF10B981)},
      {'val': s, 'color': const Color(0xFFF59E0B)},
      {'val': e, 'color': const Color(0xFF8B5CF6)},
      {'val': b, 'color': const Color(0xFFEF4444)},
      {'val': o, 'color': const Color(0xFF6B7280)},
    ];

    for (var cat in categories) {
      double sweepAngle = ((cat['val'] as double) / total) * 2 * math.pi;
      if (sweepAngle > 0) {
        canvas.drawArc(rect, startAngle, sweepAngle, false, strokePaint..color = cat['color'] as Color);
        startAngle += sweepAngle;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}