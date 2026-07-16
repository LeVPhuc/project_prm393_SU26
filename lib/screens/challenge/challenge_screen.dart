import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/challenge_model.dart';
import '../../models/wallet_model.dart';
import '../../models/transaction_model.dart';
import '../../services/mock_data.dart';
import '../../theme/app_theme.dart';
import '../main_navigation.dart';
import '../../utils/currency/currency_parser.dart';
import '../../utils/currency/currency_text_field.dart';

class ChallengeScreen extends StatefulWidget {
  const ChallengeScreen({super.key});

  @override
  State<ChallengeScreen> createState() => _ChallengeScreenState();
}

class _ChallengeScreenState extends State<ChallengeScreen> {
  String _selectedFilter = 'active'; // 'all', 'active', 'completed', 'failed'
  String _selectedPriceFilter = 'all'; // 'all', 'under_1m', '1m_5m', '5m_10m', 'over_10m'

  List<ChallengeModel> get _filteredChallenges {
    return MockData.challenges.where((c) {
      // 1. Lọc theo trạng thái
      bool matchStatus = true;
      switch (_selectedFilter) {
        case 'active':
          matchStatus = c.status == ChallengeStatus.active || c.status == ChallengeStatus.pending;
          break;
        case 'completed':
          matchStatus = c.status == ChallengeStatus.completed;
          break;
        case 'failed':
          matchStatus = c.status == ChallengeStatus.failed || c.status == ChallengeStatus.forfeited;
          break;
        default:
          matchStatus = true;
      }
      if (!matchStatus) return false;

      // 2. Lọc theo khoảng giá tiết kiệm
      switch (_selectedPriceFilter) {
        case 'under_1m':
          return c.targetAmount < 1000000;
        case '1m_5m':
          return c.targetAmount >= 1000000 && c.targetAmount <= 5000000;
        case '5m_10m':
          return c.targetAmount > 5000000 && c.targetAmount <= 10000000;
        case 'over_10m':
          return c.targetAmount > 10000000;
        default:
          return true;
      }
    }).toList();
  }

  void _showAddChallengeSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddChallengeSheet(
        onSaved: () {
          setState(() {});
        },
      ),
    );
  }

  void _showChallengeActionSheet(BuildContext context, ChallengeModel challenge) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateSheet) {
            return Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkBg : Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
              ),
              padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(challenge.icon, style: const TextStyle(fontSize: 26)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            challenge.title,
                            style: Theme.of(context).textTheme.displayMedium,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      challenge.description.isNotEmpty ? challenge.description : 'Không có mô tả',
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                    ),
                    const Divider(height: 24),
                    
                    // Chi tiết thông tin cược & tiến trình
                    _buildDetailRow('Hạn mức / Mục tiêu:', formatter.format(challenge.spendLimit)),
                    _buildDetailRow('Thực tế hiện tại:', formatter.format(challenge.actualSpent)),
                    _buildDetailRow('Tiền đặt cược:', formatter.format(challenge.betAmount)),
                    _buildDetailRow('Thời hạn còn lại:', '${challenge.daysLeft} ngày'),
                    _buildDetailRow('Chuỗi kỷ luật:', '🔥 ${challenge.currentStreak} ngày'),
                    _buildDetailRow('Khiên bảo vệ còn:', '🛡️ ${challenge.shields} mạng'),
                    _buildDetailRow(
                      'Trạng thái thách đấu:',
                      challenge.status == ChallengeStatus.active
                          ? '🔒 ĐANG CHẠY'
                          : challenge.status == ChallengeStatus.failed
                              ? '❌ THẤT BẠI (Mất cược)'
                              : challenge.status == ChallengeStatus.completed
                                  ? '✅ THÀNH CÔNG (Thu hồi cược)'
                                  : '🏳️ ĐÃ HUỶ',
                    ),

                    // Chế độ cược AI Duel
                    _buildAiDuelSection(challenge),

                    // Biểu đồ Timeline lịch sử chi tiêu
                    _buildTimelineChart(challenge),

                    // Cửa hàng mua Khiên bằng XP
                    _buildShieldStore(challenge, setStateSheet),

                    const Divider(height: 28),

                    // Các nút hành động tùy theo trạng thái
                    if (challenge.status == ChallengeStatus.active) ...[
                      // Nếu là tích lũy, cho phép gửi tiết kiệm thêm
                      if (challenge.betAmount == 0 || challenge.title.toLowerCase().contains('tiết kiệm') || challenge.title.toLowerCase().contains('mua'))
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                            icon: const Icon(Icons.savings_rounded, color: Colors.white),
                            label: const Text('Gửi tiết kiệm thêm', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            onPressed: () {
                              Navigator.pop(context);
                              _showDepositSavingsDialog(context, challenge);
                            },
                          ),
                        )
                      else
                        // Nếu là cược chi tiêu, cho phép xác nhận hoàn thành sớm nếu giữ vững kỷ luật
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
                            icon: const Icon(Icons.verified_rounded, color: Colors.white),
                            label: const Text('Hoàn thành & Nhận lại cược', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            onPressed: () {
                              Navigator.pop(context);
                              _completeChallenge(challenge);
                            },
                          ),
                        ),
                      const SizedBox(height: 12),
                      // Nút đầu hàng / Hủy thách đấu
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                          ),
                          icon: const Icon(Icons.flag_rounded),
                          label: const Text('Bỏ cuộc (Chấp nhận phạt cược)'),
                          onPressed: () {
                            Navigator.pop(context);
                            _forfeitChallenge(challenge);
                          },
                        ),
                      ),
                    ] else ...[
                      // Nếu đã kết thúc, cho phép xóa thử thách khỏi lịch sử
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[800]),
                          icon: const Icon(Icons.delete_sweep_rounded, color: Colors.white),
                          label: const Text('Xóa khỏi lịch sử', style: TextStyle(color: Colors.white)),
                          onPressed: () {
                            setState(() {
                              MockData.challenges.removeWhere((c) => c.id == challenge.id);
                            });
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAiDuelSection(ChallengeModel challenge) {
    if (!challenge.isAiDuel) return const SizedBox();
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);
    final userBetter = challenge.actualSpent <= challenge.aiSpent;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('🤖', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  const Text(
                    'Đối Kháng AI Duel (Vun Vén Bot)',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primary),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: userBetter ? AppColors.success.withValues(alpha: 0.2) : AppColors.accent.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      userBetter ? 'Bạn Thắng' : 'AI Dẫn Đầu',
                      style: TextStyle(
                        color: userBetter ? AppColors.success : AppColors.accent,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Chi tiêu của bạn:', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                      Text(formatter.format(challenge.actualSpent), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    ],
                  ),
                  const Icon(Icons.compare_arrows_rounded, color: AppColors.textMuted),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('Chi tiêu của AI:', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                      Text(formatter.format(challenge.aiSpent), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                userBetter
                    ? '👍 Tuyệt vời! Bạn đang chi tiêu ít hơn AI. Tiếp tục giữ vững kỷ luật để thắng trọn Pool cược!'
                    : '⚠️ Cảnh báo! AI đang tiết kiệm tốt hơn bạn. Hãy hạn chế chi tiêu để lội ngược dòng!',
                style: TextStyle(
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                  color: userBetter ? Colors.green[300] : Colors.red[300],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineChart(ChallengeModel challenge) {
    if (challenge.dailySpending.isEmpty) return const SizedBox();
    
    final formatter = NumberFormat.compactCurrency(locale: 'vi_VN', symbol: '₫');
    final maxSpent = challenge.dailySpending.fold(1.0, (double m, double val) => val > m ? val : m);
    // Tính toán hạn mức ngày lý thuyết (Ví dụ: spendLimit / tổng số ngày thử thách)
    final dailyLimit = challenge.spendLimit / 30; // Giả sử trung bình 30 ngày

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text(
          '📊 Lịch sử chi tiêu hàng ngày (Thực tế vs Ngân sách ngày)',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        const SizedBox(height: 12),
        Container(
          height: 100,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: challenge.dailySpending.asMap().entries.map((entry) {
              final idx = entry.key;
              final spentVal = entry.value;
              final percentage = (spentVal / maxSpent).clamp(0.0, 1.0);
              final barHeight = percentage * 60;
              final isOver = spentVal > dailyLimit;

              return Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(formatter.format(spentVal), style: const TextStyle(fontSize: 8, color: AppColors.textMuted)),
                  const SizedBox(height: 4),
                  Container(
                    width: 16,
                    height: barHeight == 0 ? 3 : barHeight,
                    decoration: BoxDecoration(
                      color: isOver ? AppColors.accent : AppColors.primary,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(4),
                        topRight: Radius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('N${idx + 1}', style: const TextStyle(fontSize: 8, color: AppColors.textMuted)),
                ],
              );
            }).toList(),
          ),
        ),
        if (dailyLimit > 0)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 8),
            child: Row(
              children: [
                Container(width: 8, height: 8, color: AppColors.primary, margin: const EdgeInsets.only(right: 6)),
                Text('Hạn mức ngày: ${formatter.format(dailyLimit)}', style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
                const SizedBox(width: 12),
                Container(width: 8, height: 8, color: AppColors.accent, margin: const EdgeInsets.only(right: 6)),
                const Text('Vượt hạn mức ngày (Bị cảnh báo)', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildShieldStore(ChallengeModel challenge, StateSetter setStateSheet) {
    if (challenge.status != ChallengeStatus.active) return const SizedBox();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.secondary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.secondary.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              const Text('🛡️', style: TextStyle(fontSize: 22)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Trạm cứu hộ: Mua Khiên', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.secondaryLight)),
                    Text(
                      'Dùng 100 XP để đổi 1 Khiên bảo vệ. Bạn có: ${MockData.currentXP} XP.',
                      style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                onPressed: MockData.currentXP < 100
                    ? null
                    : () {
                        // Trừ XP
                        MockData.currentXP -= 100;
                        // Cộng khiên
                        final cIdx = MockData.challenges.indexOf(challenge);
                        if (cIdx != -1) {
                          MockData.challenges[cIdx] = challenge.copyWith(
                            shields: challenge.shields + 1,
                          );
                          
                          // Cập nhật giao diện bên trong Sheet và bên ngoài Screen
                          setStateSheet(() {});
                          setState(() {});
                        }
                        
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: AppColors.success,
                            content: Text('🛡️ Mua khiên bảo vệ thành công! Đã kích hoạt khiên cứu mạng.'),
                          ),
                        );
                      },
                child: const Text('Mua (100XP)', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showDepositSavingsDialog(BuildContext context, ChallengeModel challenge) {
    final controller = TextEditingController();
    WalletModel selectedWallet = MockData.wallets.first;

    showDialog(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? AppColors.darkCard : Colors.white,
          title: const Text('Gửi tiết kiệm thêm'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Tích lũy vào mục tiêu "${challenge.title}"', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
              const SizedBox(height: 12),
              DropdownButtonFormField<WalletModel>(
                initialValue: selectedWallet,
                decoration: const InputDecoration(labelText: 'Trích từ ví'),
                dropdownColor: isDark ? AppColors.darkCard : Colors.white,
                items: MockData.wallets.map((w) {
                  return DropdownMenuItem(
                    value: w,
                    child: Text('${w.icon} ${w.name} (${NumberFormat.compactCurrency(locale: 'vi_VN', symbol: '₫').format(w.balance)})'),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) selectedWallet = val;
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                keyboardType: const TextInputType.numberWithOptions(decimal: false, signed: false),
                inputFormatters: [VndCurrencyInputFormatter()],
                decoration: const InputDecoration(
                  hintText: 'Nhập số tiền gửi (đ)',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
            ElevatedButton(
              onPressed: () {
                final amount = CurrencyParser.parse(controller.text);
                if (amount <= 0) return;

                // Kiểm tra số dư ví
                if (selectedWallet.balance < amount) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Số dư ví không đủ để trích gửi tiết kiệm!')),
                  );
                  return;
                }

                // 1. Trừ tiền ví
                final wIdx = MockData.wallets.indexWhere((w) => w.id == selectedWallet.id);
                if (wIdx != -1) {
                  MockData.wallets[wIdx] = MockData.wallets[wIdx].copyWith(
                    balance: MockData.wallets[wIdx].balance - amount,
                  );
                }

                // 2. Cộng vào tiết kiệm của challenge
                final cIdx = MockData.challenges.indexWhere((c) => c.id == challenge.id);
                if (cIdx != -1) {
                  final updated = MockData.challenges[cIdx].copyWith(
                    actualSpent: MockData.challenges[cIdx].actualSpent + amount,
                  );
                  // Kiểm tra hoàn thành mục tiêu tích lũy
                  if (updated.actualSpent >= updated.spendLimit) {
                    MockData.challenges[cIdx] = updated.copyWith(status: ChallengeStatus.completed);
                    _awardChallengeXP(150, challenge.title);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: AppColors.success,
                        content: Text('🎉 Chúc mừng! Bạn đã hoàn thành mục tiêu tích lũy "${challenge.title}" và nhận +150 XP!'),
                      ),
                    );
                  } else {
                    MockData.challenges[cIdx] = updated;
                  }
                }

                // 3. Tạo một giao dịch ghi nhận tích lũy (loại chi tiêu đặc biệt)
                final newTx = TransactionModel(
                  id: 'tx_save_${DateTime.now().millisecondsSinceEpoch}',
                  walletId: selectedWallet.id,
                  amount: amount,
                  type: TransactionType.expense,
                  category: TransactionCategory.other,
                  title: 'Gửi tiết kiệm: ${challenge.title}',
                  date: DateTime.now(),
                  createdAt: DateTime.now(),
                );
                MockData.transactions.insert(0, newTx);

                setState(() {});
                Navigator.pop(context);
              },
              child: const Text('Gửi tích lũy'),
            ),
          ],
        );
      },
    );
  }

  void _awardChallengeXP(int xpAmount, String challengeTitle) {
    MockData.currentXP += xpAmount;
    bool leveledUp = false;
    int oldLevel = MockData.level;

    while (MockData.currentXP >= MockData.xpForNextLevel) {
      MockData.currentXP -= MockData.xpForNextLevel;
      MockData.level += 1;
      MockData.xpForNextLevel = MockData.level * 150;
      leveledUp = true;
    }

    if (leveledUp) {
      showDialog(
        context: context,
        builder: (context) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          return AlertDialog(
            backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: Row(
              children: [
                const Text('🎉 ', style: TextStyle(fontSize: 24)),
                Text(
                  'THĂNG CẤP MỚI!',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    fontFamily: Theme.of(context).textTheme.bodyLarge?.fontFamily,
                  ),
                ),
              ],
            ),
            content: Text(
              'Chúc mừng bạn đã thăng cấp từ Cấp $oldLevel lên Cấp ${MockData.level}!\nNhận thêm nhiều quyền lợi mới và tiếp tục kỷ luật tài chính nhé! 💪',
              style: const TextStyle(fontSize: 14),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Tuyệt vời', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          );
        },
      );
    }
    setState(() {});
  }

  void _completeChallenge(ChallengeModel challenge) {
    final cIdx = MockData.challenges.indexOf(challenge);
    if (cIdx != -1) {
      // 1. Đổi trạng thái thành completed
      MockData.challenges[cIdx] = challenge.copyWith(status: ChallengeStatus.completed);
      
      // 2. Trả lại tiền cược vào ví liên kết
      if (challenge.betAmount > 0) {
        final wIdx = MockData.wallets.indexWhere((w) => w.id == challenge.walletId);
        if (wIdx != -1) {
          final w = MockData.wallets[wIdx];
          MockData.wallets[wIdx] = w.copyWith(balance: w.balance + challenge.betAmount);
        }
      }

      _awardChallengeXP(150, challenge.title);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.success,
          content: Text('🏆 Thành công xuất sắc! Hoàn tất thách đấu "${challenge.title}" (Nhận lại ${NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0).format(challenge.betAmount)} tiền cược & +150 XP)!'),
        ),
      );
      setState(() {});
    }
  }

  void _forfeitChallenge(ChallengeModel challenge) {
    final cIdx = MockData.challenges.indexOf(challenge);
    if (cIdx != -1) {
      // 1. Đổi trạng thái thành forfeited
      MockData.challenges[cIdx] = challenge.copyWith(status: ChallengeStatus.forfeited);
      
      // 2. Ghi nhận phạt cược: Tiền cược đã bị trừ trước đó lúc tạo nên ở đây không cần trừ thêm,
      //    chỉ hiển thị thông báo nóng cảnh báo mất cược
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.accent,
          content: Text('🏳️ Bạn đã bỏ cuộc! Thử thách "${challenge.title}" thất bại và bạn bị phạt mất khoản cược ${NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0).format(challenge.betAmount)}!'),
        ),
      );
      setState(() {});
    }
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);
    final filteredList = _filteredChallenges;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 140,
            pinned: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
              onPressed: () {
                final navState = context.findAncestorStateOfType<MainNavigationState>();
                if (navState != null) {
                  navState.onTabTapped(0);
                }
              },
            ),
            backgroundColor: const Color(0xFF1E1B4B),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF0F172A), Color(0xFF1E1B4B), Color(0xFF4F46E5)],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text('🎯', style: TextStyle(fontSize: 28)),
                            const SizedBox(width: 10),
                            const Text(
                              'Thử thách',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  const Text('⭐', style: TextStyle(fontSize: 12)),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${MockData.currentXP} XP',
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${MockData.activeChallengeCount} thử thách đang chạy',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.65),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Add challenge button
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
              child: ElevatedButton.icon(
                onPressed: () => _showAddChallengeSheet(context),
                icon: const Icon(Icons.add_rounded, color: Colors.white),
                label: const Text('Tạo thử thách mới', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ),

          // Filter bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('active', 'Đang chạy'),
                    const SizedBox(width: 8),
                    _buildFilterChip('completed', 'Thành công'),
                    const SizedBox(width: 8),
                    _buildFilterChip('failed', 'Thất bại'),
                    const SizedBox(width: 8),
                    _buildFilterChip('all', 'Tất cả'),
                  ],
                ),
              ),
            ),
          ),

          // Price range filter bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 2),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildPriceFilterChip('all', 'Tất cả khoảng giá'),
                    const SizedBox(width: 8),
                    _buildPriceFilterChip('under_1m', 'Dưới 1M'),
                    const SizedBox(width: 8),
                    _buildPriceFilterChip('1m_5m', '1M - 5M'),
                    const SizedBox(width: 8),
                    _buildPriceFilterChip('5m_10m', '5M - 10M'),
                    const SizedBox(width: 8),
                    _buildPriceFilterChip('over_10m', 'Trên 10M'),
                  ],
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
              child: Text(
                _selectedFilter == 'active'
                    ? 'Đang thực hiện'
                    : _selectedFilter == 'completed'
                        ? 'Đã hoàn thành'
                        : _selectedFilter == 'failed'
                            ? 'Lịch sử thất bại / hủy bỏ'
                            : 'Tất cả thử thách',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
          ),

          if (filteredList.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
                child: Center(
                  child: Column(
                    children: [
                      const Text('🎯', style: TextStyle(fontSize: 48)),
                      const SizedBox(height: 12),
                      Text(
                        'Không tìm thấy thử thách nào.',
                        style: TextStyle(color: isDark ? Colors.white38 : Colors.black38),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildListDelegate(
                filteredList.map((challenge) {
                  return GestureDetector(
                    onTap: () => _showChallengeActionSheet(context, challenge),
                    child: _ChallengeCard(
                      challenge: challenge,
                      formatter: formatter,
                      isDark: isDark,
                    ),
                  );
                }).toList(),
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String filterKey, String label) {
    final isSelected = _selectedFilter == filterKey;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppColors.primary.withValues(alpha: 0.15),
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : AppColors.textMuted,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      onSelected: (selected) {
        if (selected) {
          setState(() => _selectedFilter = filterKey);
        }
      },
    );
  }

  Widget _buildPriceFilterChip(String filterKey, String label) {
    final isSelected = _selectedPriceFilter == filterKey;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppColors.secondary.withValues(alpha: 0.15),
      labelStyle: TextStyle(
        color: isSelected ? AppColors.secondary : AppColors.textMuted,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      onSelected: (selected) {
        if (selected) {
          setState(() => _selectedPriceFilter = filterKey);
        }
      },
    );
  }
}

class _ChallengeCard extends StatelessWidget {
  final Challenge challenge;
  final NumberFormat formatter;
  final bool isDark;

  const _ChallengeCard({
    required this.challenge,
    required this.formatter,
    required this.isDark,
  });

  Color get _progressColor {
    if (challenge.status == ChallengeStatus.failed || challenge.status == ChallengeStatus.forfeited) {
      return AppColors.accent;
    }
    if (challenge.status == ChallengeStatus.completed) {
      return AppColors.success;
    }
    if (challenge.progress >= 0.8) return AppColors.success;
    if (challenge.progress >= 0.5) return AppColors.warning;
    return AppColors.secondary;
  }

  @override
  Widget build(BuildContext context) {
    final progress = challenge.progress.clamp(0.0, 1.0);
    final isFailed = challenge.status == ChallengeStatus.failed || challenge.status == ChallengeStatus.forfeited;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? AppColors.darkBorder.withValues(alpha: 0.5) : AppColors.lightBorder,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: _progressColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(challenge.icon, style: const TextStyle(fontSize: 26)),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              challenge.title,
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                decoration: isFailed ? TextDecoration.lineThrough : null,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (challenge.isAiDuel)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              margin: const EdgeInsets.only(left: 6),
                              decoration: BoxDecoration(
                                color: Colors.blue[900]?.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                '🤖 Đấu AI',
                                style: TextStyle(color: Colors.blue, fontSize: 8, fontWeight: FontWeight.bold),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        challenge.description.isNotEmpty ? challenge.description : 'Thử thách Self-Gambling',
                        style: Theme.of(context).textTheme.bodyMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isFailed
                        ? Colors.red[800]?.withValues(alpha: 0.15)
                        : challenge.status == ChallengeStatus.completed
                            ? Colors.green[800]?.withValues(alpha: 0.15)
                            : challenge.daysLeft <= 10
                                ? AppColors.accent.withValues(alpha: 0.15)
                                : AppColors.darkBorder.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isFailed
                        ? 'Thất bại'
                        : challenge.status == ChallengeStatus.completed
                            ? 'Hoàn thành'
                            : '${challenge.daysLeft} ngày',
                    style: TextStyle(
                      color: isFailed
                          ? Colors.red[400]
                          : challenge.status == ChallengeStatus.completed
                              ? Colors.green[400]
                              : challenge.daysLeft <= 10
                                  ? AppColors.accent
                                  : AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            // Progress bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formatter.format(challenge.savedAmount),
                  style: TextStyle(
                    color: _progressColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                Text(
                  formatter.format(challenge.targetAmount),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
                valueColor: AlwaysStoppedAnimation<Color>(_progressColor),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    if (challenge.betAmount > 0) ...[
                      const Icon(Icons.lock_outline_rounded, size: 12, color: AppColors.textMuted),
                      const SizedBox(width: 3),
                      Text(
                        'Cược: ${formatter.format(challenge.betAmount)}',
                        style: const TextStyle(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(width: 10),
                    ],
                    if (challenge.shields > 0) ...[
                      const Text('🛡️', style: TextStyle(fontSize: 11)),
                      const SizedBox(width: 2),
                      Text(
                        '${challenge.shields}',
                        style: const TextStyle(fontSize: 11, color: AppColors.secondaryLight, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 10),
                    ],
                    if (challenge.currentStreak > 0) ...[
                      const Text('🔥', style: TextStyle(fontSize: 11)),
                      const SizedBox(width: 2),
                      Text(
                        '${challenge.currentStreak} ngày',
                        style: const TextStyle(fontSize: 11, color: Colors.orange, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ],
                ),
                Text(
                  '${(progress * 100).toStringAsFixed(0)}% ${isFailed ? "vượt hạn mức" : "hoàn thành"}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// ADD NEW CHALLENGE SHEET
// ─────────────────────────────────────────────────────────────
class _AddChallengeSheet extends StatefulWidget {
  final VoidCallback onSaved;

  const _AddChallengeSheet({required this.onSaved});

  @override
  State<_AddChallengeSheet> createState() => _AddChallengeSheetState();
}

class _AddChallengeSheetState extends State<_AddChallengeSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _limitController = TextEditingController();
  final _betController = TextEditingController();

  String _selectedType = 'saving'; // 'saving' or 'self_gambling'
  String _selectedEmoji = '🎯';
  int _selectedDuration = 30; // days
  late WalletModel _selectedWallet;
  bool _enableAiDuel = false;
  int _initialShields = 0;
  String _selectedPriceRange = 'all'; // 'all', 'under_1m', '1m_5m', '5m_10m', 'over_10m'

  final List<String> _emojis = ['🎯', '📱', '🥗', '🌄', '🛡️', '✈️', '🛒', '🍜', '🚗'];

  Widget _buildRangeChip(String rangeKey, String label) {
    final isSelected = _selectedPriceRange == rangeKey;
    return ChoiceChip(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      label: Text(label, style: const TextStyle(fontSize: 11)),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedPriceRange = selected ? rangeKey : 'all';
        });
      },
    );
  }

  List<double> _getSuggestedAmountsForRange(String range) {
    switch (range) {
      case 'under_1m':
        return [200000.0, 500000.0, 800000.0];
      case '1m_5m':
        return [1000000.0, 2000000.0, 3000000.0, 5000000.0];
      case '5m_10m':
        return [6000000.0, 7500000.0, 9000000.0, 10000000.0];
      case 'over_10m':
        return [15000000.0, 20000000.0, 30000000.0, 50000000.0];
      default:
        return [];
    }
  }

  @override
  void initState() {
    super.initState();
    _selectedWallet = MockData.wallets.first;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _limitController.dispose();
    _betController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final limit = CurrencyParser.parse(_limitController.text);
    final bet = _selectedType == 'self_gambling'
        ? CurrencyParser.parse(_betController.text)
        : 0.0;

    if (limit <= 0) return;

    // Chi phí mua khiên ban đầu (Mỗi khiên tốn 100 XP)
    final shieldCostXp = _initialShields * 100;
    if (shieldCostXp > MockData.currentXP) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không đủ XP để mua $_initialShields Khiên bảo vệ! (Bạn có ${MockData.currentXP} XP, cần $shieldCostXp XP)')),
      );
      return;
    }

    // Phạt cược đóng băng trước từ ví tài khoản
    if (bet > 0) {
      if (_selectedWallet.balance < bet) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Số dư ví không đủ để thực hiện cược thử thách này!')),
        );
        return;
      }

      final wIdx = MockData.wallets.indexWhere((w) => w.id == _selectedWallet.id);
      if (wIdx != -1) {
        MockData.wallets[wIdx] = MockData.wallets[wIdx].copyWith(
          balance: MockData.wallets[wIdx].balance - bet,
        );
      }
    }

    // Trừ XP nếu có mua khiên
    if (shieldCostXp > 0) {
      MockData.currentXP -= shieldCostXp;
    }

    final newChallenge = ChallengeModel(
      id: 'c_new_${DateTime.now().millisecondsSinceEpoch}',
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      icon: _selectedEmoji,
      walletId: _selectedWallet.id,
      spendLimit: limit,
      betAmount: bet,
      startDate: DateTime.now(),
      endDate: DateTime.now().add(Duration(days: _selectedDuration)),
      status: ChallengeStatus.active,
      actualSpent: 0.0,
      shields: _initialShields,
      isAiDuel: _enableAiDuel,
      aiSpent: _enableAiDuel ? 0.0 : 0.0, // AI bắt đầu từ 0
      currentStreak: 0,
      dailySpending: const [0.0],
    );

    // Chèn vào MockData
    MockData.challenges.insert(0, newChallenge);

    // Thông báo nóng
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.success,
        content: Text(
          bet > 0
              ? '🔒 Tạo thử thách cược thành công! Đóng băng ${NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0).format(bet)} tiền cược. ${_initialShields > 0 ? "Trang bị $_initialShields Khiên." : ""}'
              : '🎉 Tạo mục tiêu tích lũy thành công!',
        ),
      ),
    );

    widget.onSaved();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBg : Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.black12,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Tạo thử thách mới', style: Theme.of(context).textTheme.displayMedium),
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded)),
                ],
              ),
              const Divider(height: 20),

              // Loại thử thách
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(child: Text('Tích lũy tiết kiệm', style: TextStyle(fontWeight: FontWeight.bold))),
                      selected: _selectedType == 'saving',
                      onSelected: (val) {
                        if (val) setState(() => _selectedType = 'saving');
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(child: Text('Tự kỷ phạt cược', style: TextStyle(fontWeight: FontWeight.bold))),
                      selected: _selectedType == 'self_gambling',
                      onSelected: (val) {
                        if (val) setState(() => _selectedType = 'self_gambling');
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Title
              const Text('Tên thử thách', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(hintText: 'Ví dụ: Mua laptop, Hạn chế ăn vặt...'),
                validator: (v) => (v == null || v.isEmpty) ? 'Vui lòng nhập tên thử thách' : null,
              ),
              const SizedBox(height: 16),

              // Desc
              const Text('Mô tả ngắn', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(hintText: 'Mục đích hoặc chi tiết luật chơi...'),
              ),
              const SizedBox(height: 16),

              // Target / Limit
              Text(
                _selectedType == 'saving' ? 'Số tiền cần tích lũy (đ)' : 'Hạn mức chi tiêu tối đa (đ)',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _limitController,
                keyboardType: const TextInputType.numberWithOptions(decimal: false, signed: false),
                inputFormatters: [VndCurrencyInputFormatter()],
                decoration: const InputDecoration(hintText: '0'),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Vui lòng nhập số tiền';
                  final parsed = CurrencyParser.parse(v);
                  if (parsed <= 0) return 'Số tiền không hợp lệ';
                  return null;
                },
              ),
              const SizedBox(height: 8),

              // Khoảng giá trị gợi ý và nút điền nhanh số tiền (chỉ khi là thử thách tiết kiệm/tích lũy)
              if (_selectedType == 'saving') ...[
                const Text('Chọn nhanh khoảng tiền tiết kiệm:', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                const SizedBox(height: 6),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildRangeChip('under_1m', 'Dưới 1M'),
                      const SizedBox(width: 6),
                      _buildRangeChip('1m_5m', '1M - 5M'),
                      const SizedBox(width: 6),
                      _buildRangeChip('5m_10m', '5M - 10M'),
                      const SizedBox(width: 6),
                      _buildRangeChip('over_10m', 'Trên 10M'),
                    ],
                  ),
                ),
                if (_selectedPriceRange != 'all') ...[
                  const SizedBox(height: 8),
                  const Text('Giá trị cụ thể gợi ý:', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                  const SizedBox(height: 6),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _getSuggestedAmountsForRange(_selectedPriceRange).map((val) {
                        final formattedVal = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0).format(val);
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: ActionChip(
                            backgroundColor: isDark ? AppColors.darkSurface : Colors.grey[200],
                            side: BorderSide.none,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            label: Text(
                              formattedVal,
                              style: TextStyle(
                                fontSize: 11.5,
                                color: isDark ? Colors.white70 : Colors.black87,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            onPressed: () {
                              // Định dạng chuỗi không dấu để lưu/hiển thị
                              final rawVal = NumberFormat.currency(locale: 'vi_VN', symbol: '', decimalDigits: 0).format(val).trim();
                              _limitController.text = rawVal;
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ],
              const SizedBox(height: 16),

              // Bet Amount (only if self-gambling)
              if (_selectedType == 'self_gambling') ...[
                const Text('Số tiền cược phạt (đ) - Sẽ đóng băng từ ví của bạn', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.accent)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _betController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: false, signed: false),
                  inputFormatters: [VndCurrencyInputFormatter()],
                  decoration: const InputDecoration(hintText: '0'),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Vui lòng nhập số tiền cược';
                    final parsed = CurrencyParser.parse(v);
                    if (parsed < 0) return 'Số tiền cược không hợp lệ';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Switch Đấu AI Duel
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('🤖 Thách đấu đối kháng AI (AI Duel)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        Text('Thi tài chi tiêu kỷ luật cùng Vun Vén Bot', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                      ],
                    ),
                    Switch(
                      value: _enableAiDuel,
                      activeTrackColor: AppColors.primary,
                      onChanged: (val) => setState(() => _enableAiDuel = val),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Chọn số lượng khiên bảo hộ ban đầu
                const Text('🛡️ Trang bị Khiên bảo vệ ban đầu (100 XP / Khiên)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 8),
                Row(
                  children: [0, 1, 2].map((count) {
                    final isSel = _initialShields == count;
                    final xpCost = count * 100;
                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: ChoiceChip(
                        label: Text(count == 0 ? 'Không dùng' : '$count Khiên ($xpCost XP)'),
                        selected: isSel,
                        onSelected: (val) {
                          if (val) setState(() => _initialShields = count);
                        },
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
              ],

              // Wallet select
              const Text('Ví liên kết', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 6),
              DropdownButtonFormField<WalletModel>(
                initialValue: _selectedWallet,
                dropdownColor: isDark ? AppColors.darkCard : Colors.white,
                items: MockData.wallets.map((w) {
                  return DropdownMenuItem(
                    value: w,
                    child: Text('${w.icon} ${w.name}'),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedWallet = val);
                },
              ),
              const SizedBox(height: 16),

              // Duration
              const Text('Thời hạn thử thách', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 8),
              Row(
                children: [7, 30, 90].map((days) {
                  final isSel = _selectedDuration == days;
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: ChoiceChip(
                      label: Text('$days ngày'),
                      selected: isSel,
                      onSelected: (val) {
                        if (val) setState(() => _selectedDuration = days);
                      },
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Emoji selector
              const Text('Chọn biểu tượng', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _emojis.map((emoji) {
                  final isSel = _selectedEmoji == emoji;
                  return InkWell(
                    onTap: () => setState(() => _selectedEmoji = emoji),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isSel ? AppColors.primary.withValues(alpha: 0.15) : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSel ? AppColors.primary : Colors.grey.withValues(alpha: 0.2),
                          width: 1.5,
                        ),
                      ),
                      child: Text(emoji, style: const TextStyle(fontSize: 22)),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 28),

              // Submit
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _save,
                  child: const Text('Kích hoạt thử thách', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
