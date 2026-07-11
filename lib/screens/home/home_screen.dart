import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/app_state.dart';
import '../../services/mock_data.dart';
import '../../models/transaction_model.dart';
import '../../models/challenge_model.dart';
import '../../models/wallet_model.dart';
import '../../theme/app_theme.dart';
import '../main_navigation.dart';
import '../../utils/currency/currency_parser.dart';
import '../../utils/currency/currency_text_field.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final _formatter =
      NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  bool _hideBalance = false;
  String _selectedFilter = 'all'; // 'all', 'income', 'expense'

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Chào buổi sáng ☀️';
    if (hour < 18) return 'Chào buổi chiều 🌤️';
    return 'Chào buổi tối 🌙';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final userName = AppState().userName;
    final nearest = MockData.nearestChallenge;
    final xpProgress = MockData.currentXP / MockData.xpForNextLevel;

    // Lọc danh sách giao dịch dựa trên filter được chọn
    final filteredTxns = MockData.transactions.where((t) {
      if (_selectedFilter == 'income') return t.type == TransactionType.income;
      if (_selectedFilter == 'expense') return t.type == TransactionType.expense;
      return true;
    }).toList();

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBg : const Color(0xFFF0FDF9),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SlideTransition(
          position: _slideAnim,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ─── HEADER ───────────────────────────────────────────────
              SliverToBoxAdapter(
                child: _buildHeader(isDark, userName),
              ),

              // ─── INFO CARDS GRID ──────────────────────────────────────
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Tổng tài sản - Gõ vào để ẩn/hiện số dư
                    _TotalBalanceCard(
                      formatter: _formatter,
                      isDark: isDark,
                      hideBalance: _hideBalance,
                      onToggleHideBalance: () {
                        setState(() => _hideBalance = !_hideBalance);
                      },
                      selectedFilter: _selectedFilter,
                      onFilterChanged: (filter) {
                        setState(() => _selectedFilter = filter);
                      },
                    ),
                    const SizedBox(height: 14),
                    // Quỹ đóng băng + Challenge đang chạy (side by side)
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _showFrozenFundsDetailSheet(),
                            child: _InfoCard(
                              icon: '🧊',
                              label: 'Quỹ đóng băng',
                              value: _hideBalance ? '••••••' : _formatter.format(MockData.frozenAmount),
                              sublabel: 'Đang khóa trong challenge',
                              color: const Color(0xFF38BDF8),
                              isDark: isDark,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              final navState = context.findAncestorStateOfType<MainNavigationState>();
                              if (navState != null) {
                                navState.onTabTapped(1); // Chuyển sang Tab Thử thách
                              }
                            },
                            child: _InfoCard(
                              icon: '⚡',
                              label: 'Challenge đang chạy',
                              value: '${MockData.activeChallengeCount}',
                              sublabel: 'challenge hoạt động',
                              color: AppColors.warning,
                              isDark: isDark,
                              isLargeValue: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    // Level & XP Card - Gõ vào để xem danh hiệu
                    GestureDetector(
                      onTap: () => _showLevelBadgesSheet(),
                      child: _LevelXpCard(
                        xp: MockData.currentXP,
                        level: MockData.level,
                        xpForNext: MockData.xpForNextLevel,
                        xpProgress: xpProgress,
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(height: 22),

                    // ─── CHALLENGE GẦN NHẤT ────────────────────────────
                    if (nearest != null) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Thử thách gần nhất',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          TextButton(
                            onPressed: () {
                              final navState = context.findAncestorStateOfType<MainNavigationState>();
                              if (navState != null) {
                                navState.onTabTapped(1); // Chuyển sang Tab Thử thách
                              }
                            },
                            child: const Text('Xem tất cả'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () => _showChallengeDetailDialog(nearest),
                        child: _NearestChallengeCard(
                          challenge: nearest,
                          formatter: _formatter,
                          isDark: isDark,
                          hideBalance: _hideBalance,
                        ),
                      ),
                      const SizedBox(height: 22),
                    ],

                    // ─── GIAO DỊCH GẦN ĐÂY ────────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Giao dịch gần đây',
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            if (_selectedFilter != 'all') ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  _selectedFilter == 'income' ? 'Chỉ thu' : 'Chỉ chi',
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              IconButton(
                                constraints: const BoxConstraints(),
                                padding: EdgeInsets.zero,
                                icon: const Icon(Icons.close_rounded, size: 16, color: AppColors.textMuted),
                                onPressed: () => setState(() => _selectedFilter = 'all'),
                              ),
                            ],
                          ],
                        ),
                        TextButton(
                          onPressed: () {
                            final navState = context.findAncestorStateOfType<MainNavigationState>();
                            if (navState != null) {
                              navState.onTabTapped(2); // Chuyển sang Tab Ví tiền
                            }
                          },
                          child: const Text('Xem tất cả'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ]),
                ),
              ),

              // Transaction list
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate(
                    filteredTxns.isEmpty
                        ? [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 24),
                              child: Center(
                                child: Text(
                                  'Không có giao dịch nào khớp với bộ lọc.',
                                  style: TextStyle(color: isDark ? Colors.white38 : Colors.black38),
                                ),
                              ),
                            ),
                          ]
                        : filteredTxns.map((tx) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: GestureDetector(
                                onTap: () => _showTransactionDetailSheet(tx),
                                child: _TransactionTile(
                                  transaction: tx,
                                  formatter: _formatter,
                                  isDark: isDark,
                                ),
                              ),
                            );
                          }).toList(),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      ),
      // FAB thêm giao dịch
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTransactionBottomSheet(context),
        backgroundColor: AppColors.primary,
        elevation: 4,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'Thêm giao dịch',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark, String userName) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0F172A),
            Color(0xFF0D4A42),
            Color(0xFF0D9488),
          ],
          stops: [0.0, 0.5, 1.0],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(36),
          bottomRight: Radius.circular(36),
        ),
      ),
      child: Stack(
        children: [
          // decorative circles
          Positioned(
            top: -30,
            right: -30,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          Positioned(
            top: 50,
            right: 60,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.04),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 36),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top bar
                  Row(
                    children: [
                      // Avatar
                      GestureDetector(
                        onTap: () => _showEditProfileDialog(context),
                        child: Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.primary, AppColors.secondary],
                            ),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              userName.isNotEmpty
                                  ? userName[0].toUpperCase()
                                  : 'U',
                              style: const TextStyle(
                                color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _greeting(),
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.65),
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Xin chào, $userName 👋',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Notification bell
                      GestureDetector(
                        onTap: () => _showNotificationsBottomSheet(context),
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.15),
                            ),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              const Icon(
                                Icons.notifications_outlined,
                                color: Colors.white,
                                size: 22,
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: AppColors.accent,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Date label
                  GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('📅 Hôm nay là ${DateFormat('EEEE, dd/MM/yyyy', 'vi').format(DateTime.now())}. Chúc bạn một ngày chi tiêu kỷ luật!'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        DateFormat('EEEE, dd/MM/yyyy', 'vi').format(DateTime.now()),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context) {
    final controller = TextEditingController(text: AppState().userName);
    showDialog(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? AppColors.darkCard : Colors.white,
          title: const Text('Chỉnh sửa tên hiển thị'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Nhập tên của bạn'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (controller.text.trim().isNotEmpty) {
                  final nav = Navigator.of(context);
                  await AppState().login(controller.text.trim(), AppState().userEmail);
                  if (mounted) {
                    setState(() {});
                  }
                  nav.pop();
                }
              },
              child: const Text('Lưu'),
            ),
          ],
        );
      },
    );
  }

  void _showNotificationsBottomSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkBg : Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28),
            ),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Thông báo hệ thống', style: Theme.of(context).textTheme.displayMedium),
              const Divider(height: 24),
              _buildNotificationTile('🚨 Cảnh báo chi tiêu!', 'Ví Vietcombank của bạn đã chi tiêu chạm mốc 83% hạn mức trong tuần.', '5 phút trước'),
              _buildNotificationTile('🔒 Đã đóng băng cược', 'Khoản cược 100.000₫ đã được khóa thành công cho thử thách "Hãm Phanh Trà Sữa".', '1 giờ trước'),
              _buildNotificationTile('🏆 Huy chương mới!', 'Chúc mừng! Bạn đã mở khóa danh hiệu "Đệ Nhất Kỷ Luật" do hoàn thành 3 thử thách.', '1 ngày trước'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNotificationTile(String title, String body, String time) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              Text(time, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 4),
          Text(body, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
        ],
      ),
    );
  }

  void _showFrozenFundsDetailSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeChallengeBets = MockData.challenges.where((c) => !c.isCompleted && c.betAmount > 0).toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkBg : Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28),
            ),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Chi tiết Quỹ Đóng Băng', style: Theme.of(context).textTheme.displayMedium),
              const SizedBox(height: 4),
              const Text('Số tiền cược bị khóa để đảm bảo kỷ luật tài chính', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
              const Divider(height: 24),
              if (activeChallengeBets.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: Text('Không có khoản cược nào đang bị khóa.', style: TextStyle(color: AppColors.textMuted))),
                )
              else
                ...activeChallengeBets.map((c) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Text(c.icon, style: const TextStyle(fontSize: 22)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(c.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                              Text('Ngân sách: ${_formatter.format(c.spendLimit)}', style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.lock_outline_rounded, size: 14, color: AppColors.primary),
                            const SizedBox(width: 4),
                            Text(
                              _formatter.format(c.betAmount),
                              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
            ],
          ),
        );
      },
    );
  }

  void _showLevelBadgesSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkBg : Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28),
            ),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Bộ sưu tập Huy chương', style: Theme.of(context).textTheme.displayMedium),
              const SizedBox(height: 4),
              const Text('Kỷ luật tốt giúp bạn mở khóa danh hiệu cấp độ cao hơn', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
              const Divider(height: 24),
              _buildBadgeRow('🏆 Đệ Nhất Kỷ Luật', 'Hoàn thành 3 thử thách liên tiếp không vi phạm.', true),
              _buildBadgeRow('🛍️ Hãm Phanh Mua Sắm', 'Giữ chi tiêu mua sắm dưới 500k trong tháng.', true),
              _buildBadgeRow('🛡️ Chiến Thần Tích Lũy', 'Tổng tài sản cá nhân vượt mốc 15,000,000đ.', true),
              _buildBadgeRow('🔒 Liều Ăn Nhiều', 'Hoàn thành thử thách cược lớn trên 500k.', false),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBadgeRow(String title, String desc, bool unlocked) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, decoration: unlocked ? null : TextDecoration.lineThrough)),
                Text(desc, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: unlocked ? AppColors.primary.withValues(alpha: 0.15) : AppColors.textMuted.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              unlocked ? 'Đã Mở' : 'Khóa',
              style: TextStyle(
                color: unlocked ? AppColors.primary : AppColors.textMuted,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showChallengeDetailDialog(ChallengeModel challenge) {
    showDialog(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? AppColors.darkCard : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Text(challenge.icon, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  challenge.title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (challenge.description.isNotEmpty) ...[
                Text(challenge.description, style: const TextStyle(fontSize: 13, color: AppColors.textMuted)),
                const SizedBox(height: 12),
              ],
              _buildDetailRow('Hạn mức tối đa:', _formatter.format(challenge.spendLimit)),
              _buildDetailRow('Đã chi tiêu:', _formatter.format(challenge.actualSpent)),
              _buildDetailRow('Số tiền cược:', _formatter.format(challenge.betAmount)),
              _buildDetailRow('Ngày kết thúc:', DateFormat('dd/MM/yyyy').format(challenge.endDate)),
              _buildDetailRow('Trạng thái cược:', challenge.status == ChallengeStatus.active
                  ? '🔒 ĐANG CHẠY'
                  : challenge.status == ChallengeStatus.failed
                      ? '❌ THẤT BẠI'
                      : '✅ HOÀN THÀNH'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Đóng'),
            ),
          ],
        );
      },
    );
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

  void _showTransactionDetailSheet(TransactionModel tx) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isIncome = tx.type == TransactionType.income;
    // Tìm ví tương ứng
    final wallet = MockData.wallets.firstWhere((w) => w.id == tx.walletId,
        orElse: () => MockData.wallets.first);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkBg : Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28),
            ),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(tx.categoryIcon, style: const TextStyle(fontSize: 24)),
                      const SizedBox(width: 8),
                      Text('Chi tiết giao dịch', style: Theme.of(context).textTheme.displayMedium),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const Divider(height: 20),
              _buildDetailRow('Tiêu đề:', tx.title),
              _buildDetailRow('Số tiền:', '${isIncome ? '+' : '-'}${_formatter.format(tx.amount)}'),
              _buildDetailRow('Loại dòng tiền:', isIncome ? 'Thu nhập' : 'Chi tiêu'),
              _buildDetailRow('Danh mục:', tx.categoryLabel),
              _buildDetailRow('Ví giao dịch:', wallet.name),
              _buildDetailRow('Thời gian:', DateFormat('HH:mm - dd/MM/yyyy').format(tx.date)),
              if (tx.note != null && tx.note!.isNotEmpty)
                _buildDetailRow('Ghi chú:', tx.note!),
              const SizedBox(height: 24),
              // Nút xóa giao dịch
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[800],
                  ),
                  icon: const Icon(Icons.delete_forever_rounded, color: Colors.white),
                  label: const Text(
                    'Xóa giao dịch này',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    _deleteTransaction(tx);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _deleteTransaction(TransactionModel txn) {
    // 1. Xóa giao dịch khỏi MockData
    MockData.transactions.removeWhere((t) => t.id == txn.id);

    // 2. Hoàn tác số dư ví
    final walletIdx = MockData.wallets.indexWhere((w) => w.id == txn.walletId);
    if (walletIdx != -1) {
      final w = MockData.wallets[walletIdx];
      final newBalance = txn.type == TransactionType.income
          ? w.balance - txn.amount
          : w.balance + txn.amount;
      MockData.wallets[walletIdx] = w.copyWith(balance: newBalance);
    }

    // 3. Nếu là Chi tiêu và có Thách đấu liên quan -> Trừ lại tiến trình
    if (txn.type == TransactionType.expense) {
      final activeChallenges = MockData.challenges.where((c) => c.walletId == txn.walletId).toList();
      for (final challenge in activeChallenges) {
        final categoryMatch = challenge.categoryIds.isEmpty ||
            challenge.categoryIds.contains(txn.category.name);

        if (categoryMatch) {
          final challengeIdx = MockData.challenges.indexOf(challenge);
          if (challengeIdx != -1) {
            final updatedChallenge = challenge.copyWith(
              actualSpent: (challenge.actualSpent - txn.amount).clamp(0.0, double.infinity),
            );
            
            ChallengeStatus newStatus = updatedChallenge.status;
            // Nếu cược đã FAIL mà giờ chi tiêu hoàn tác kéo xuống dưới hạn mức -> khôi phục lại ACTIVE và hoàn tiền phạt
            if (updatedChallenge.status == ChallengeStatus.failed &&
                updatedChallenge.actualSpent <= updatedChallenge.spendLimit) {
              newStatus = ChallengeStatus.active;
              // Trả lại tiền phạt cược vào ví
              final betWalletIdx = MockData.wallets.indexWhere((w) => w.id == updatedChallenge.walletId);
              if (betWalletIdx != -1) {
                final bw = MockData.wallets[betWalletIdx];
                MockData.wallets[betWalletIdx] = bw.copyWith(
                  balance: bw.balance + updatedChallenge.betAmount,
                );
              }
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: AppColors.success,
                  duration: const Duration(seconds: 4),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  content: Text(
                    '✨ Hoàn tác chi tiêu! Khôi phục trạng thái hoạt động và hoàn trả ${NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0).format(updatedChallenge.betAmount)} tiền cược cho thử thách "${updatedChallenge.title}"!',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              );
            }

            MockData.challenges[challengeIdx] = updatedChallenge.copyWith(status: newStatus);
          }
        }
      }
    }

    setState(() {});
  }

  void _showAddTransactionBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddTransactionSheet(
        onSaved: () {
          setState(() {});
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// TOTAL BALANCE CARD
// ─────────────────────────────────────────────────────────────
class _TotalBalanceCard extends StatelessWidget {
  final NumberFormat formatter;
  final bool isDark;
  final bool hideBalance;
  final VoidCallback onToggleHideBalance;
  final String selectedFilter;
  final Function(String) onFilterChanged;

  const _TotalBalanceCard({
    required this.formatter,
    required this.isDark,
    required this.hideBalance,
    required this.onToggleHideBalance,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0D9488), Color(0xFF0F766E)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.07),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.account_balance_wallet_rounded,
                    color: Colors.white70,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Tổng tài sản',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.75),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: Icon(
                      hideBalance ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: Colors.white70,
                      size: 18,
                    ),
                    onPressed: onToggleHideBalance,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: onToggleHideBalance,
                child: Text(
                  hideBalance ? '•••••••• ₫' : formatter.format(MockData.totalBalance),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              // Income vs Expense mini row
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => onFilterChanged(selectedFilter == 'income' ? 'all' : 'income'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        decoration: BoxDecoration(
                          color: selectedFilter == 'income'
                              ? Colors.white.withValues(alpha: 0.2)
                              : Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: selectedFilter == 'income' ? Colors.white54 : Colors.transparent,
                            width: 1,
                          ),
                        ),
                        child: _MiniStat(
                          icon: Icons.arrow_upward_rounded,
                          label: 'Thu nhập',
                          value: hideBalance
                              ? '••••'
                              : NumberFormat.compactCurrency(
                                  locale: 'vi_VN',
                                  symbol: '₫',
                                  decimalDigits: 0,
                                ).format(MockData.totalIncome),
                          color: const Color(0xFF6EE7B7),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => onFilterChanged(selectedFilter == 'expense' ? 'all' : 'expense'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        decoration: BoxDecoration(
                          color: selectedFilter == 'expense'
                              ? Colors.white.withValues(alpha: 0.2)
                              : Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: selectedFilter == 'expense' ? Colors.white54 : Colors.transparent,
                            width: 1,
                          ),
                        ),
                        child: _MiniStat(
                          icon: Icons.arrow_downward_rounded,
                          label: 'Chi tiêu',
                          value: hideBalance
                              ? '••••'
                              : NumberFormat.compactCurrency(
                                  locale: 'vi_VN',
                                  symbol: '₫',
                                  decimalDigits: 0,
                                ).format(MockData.totalExpense),
                          color: const Color(0xFFFCA5A5),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _MiniStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 14),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.65),
                fontSize: 10,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// INFO CARD (Frozen / Challenge count)
// ─────────────────────────────────────────────────────────────
class _InfoCard extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  final String sublabel;
  final Color color;
  final bool isDark;
  final bool isLargeValue;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.sublabel,
    required this.color,
    required this.isDark,
    this.isLargeValue = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: color.withValues(alpha: 0.25),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.2)
                : color.withValues(alpha: 0.1),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    icon,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              ),
              const Spacer(),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: isLargeValue ? 32 : 18,
              fontWeight: FontWeight.w800,
              letterSpacing: isLargeValue ? -1 : -0.3,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            sublabel,
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  fontSize: 10,
                ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// LEVEL & XP CARD
// ─────────────────────────────────────────────────────────────
class _LevelXpCard extends StatelessWidget {
  final int xp;
  final int level;
  final int xpForNext;
  final double xpProgress;
  final bool isDark;

  const _LevelXpCard({
    required this.xp,
    required this.level,
    required this.xpForNext,
    required this.xpProgress,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF1E1B4B), const Color(0xFF2D2866)]
              : [const Color(0xFFEEF2FF), const Color(0xFFE0E7FF)],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.secondary.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Level badge
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.secondary.withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Lv$level',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Level $level · Nhà tiết kiệm',
                          style: TextStyle(
                            color: isDark
                                ? Colors.white
                                : AppColors.textOnLight,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Text('⭐', style: TextStyle(fontSize: 11)),
                              const SizedBox(width: 4),
                              Text(
                                '$xp XP',
                                style: const TextStyle(
                                  color: AppColors.secondaryLight,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // XP bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: xpProgress,
                        backgroundColor: isDark
                            ? AppColors.darkCard
                            : AppColors.lightCard,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.secondaryLight,
                        ),
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$xp / $xpForNext XP',
                          style: TextStyle(
                            color: isDark
                                ? AppColors.textSecondary
                                : AppColors.textSecondaryOnLight,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          'còn ${xpForNext - xp} XP lên Lv${level + 1}',
                          style: const TextStyle(
                            color: AppColors.secondaryLight,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// NEAREST CHALLENGE CARD
// ─────────────────────────────────────────────────────────────
class _NearestChallengeCard extends StatelessWidget {
  final dynamic challenge;
  final NumberFormat formatter;
  final bool isDark;
  final bool hideBalance;

  const _NearestChallengeCard({
    required this.challenge,
    required this.formatter,
    required this.isDark,
    this.hideBalance = false,
  });

  @override
  Widget build(BuildContext context) {
    final progress = challenge.progress as double;
    final daysLeft = challenge.daysLeft as int;
    final isUrgent = daysLeft <= 10;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isUrgent
              ? AppColors.accent.withValues(alpha: 0.4)
              : AppColors.primary.withValues(alpha: 0.25),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.15)
                : Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    challenge.icon as String,
                    style: const TextStyle(fontSize: 26),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      challenge.title as String,
                      style: Theme.of(context).textTheme.headlineSmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      challenge.description as String,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Days left badge
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isUrgent
                      ? AppColors.accent.withValues(alpha: 0.12)
                      : AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Text(
                      '$daysLeft',
                      style: TextStyle(
                        color: isUrgent ? AppColors.accent : AppColors.primary,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        height: 1,
                      ),
                    ),
                    Text(
                      'ngày',
                      style: TextStyle(
                        color: isUrgent ? AppColors.accent : AppColors.primary,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Progress row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                hideBalance ? '•••• ₫' : formatter.format(challenge.savedAmount),
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              Text(
                hideBalance ? '•••• ₫' : formatter.format(challenge.targetAmount),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor:
                  isDark ? AppColors.darkCard : AppColors.lightCard,
              valueColor: AlwaysStoppedAnimation<Color>(
                isUrgent ? AppColors.accent : AppColors.primary,
              ),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(progress * 100).toStringAsFixed(0)}% hoàn thành',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              if (isUrgent)
                const Text(
                  '⚠️ Sắp hết hạn!',
                  style: TextStyle(
                    color: AppColors.accent,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// TRANSACTION TILE
// ─────────────────────────────────────────────────────────────
class _TransactionTile extends StatelessWidget {
  final Transaction transaction;
  final NumberFormat formatter;
  final bool isDark;

  const _TransactionTile({
    required this.transaction,
    required this.formatter,
    required this.isDark,
  });

  Color get _categoryColor {
    switch (transaction.category) {
      case TransactionCategory.food:
        return AppColors.catFood;
      case TransactionCategory.transport:
        return AppColors.catTransport;
      case TransactionCategory.shopping:
        return AppColors.catShopping;
      case TransactionCategory.work:
        return AppColors.catWork;
      case TransactionCategory.health:
        return AppColors.catHealth;
      case TransactionCategory.entertainment:
        return AppColors.catEntertainment;
      case TransactionCategory.other:
        return AppColors.textMuted;
    }
  }

  String _timeAgo() {
    final diff = DateTime.now().difference(transaction.date);
    if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
    if (diff.inHours < 24) return '${diff.inHours} giờ trước';
    return '${diff.inDays} ngày trước';
  }

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionType.income;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? AppColors.darkBorder.withValues(alpha: 0.4)
              : AppColors.lightBorder,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: _categoryColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                transaction.categoryIcon,
                style: const TextStyle(fontSize: 22),
              ),
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.title,
                  style: Theme.of(context).textTheme.headlineSmall,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  '${transaction.categoryLabel} · ${_timeAgo()}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isIncome ? '+' : '-'}${formatter.format(transaction.amount)}',
                style: TextStyle(
                  color: isIncome ? AppColors.success : AppColors.accent,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 3),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: (isIncome ? AppColors.success : AppColors.accent)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isIncome ? 'Thu' : 'Chi',
                  style: TextStyle(
                    color: isIncome ? AppColors.success : AppColors.accent,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// ADD TRANSACTION BOTTOM SHEET WIDGET
// ─────────────────────────────────────────────────────────────
class _AddTransactionSheet extends StatefulWidget {
  final VoidCallback onSaved;

  const _AddTransactionSheet({required this.onSaved});

  @override
  State<_AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends State<_AddTransactionSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  
  TransactionType _selectedType = TransactionType.expense;
  TransactionCategory _selectedCategory = TransactionCategory.food;
  late WalletModel _selectedWallet;

  @override
  void initState() {
    super.initState();
    _selectedWallet = MockData.wallets.first;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final amount = CurrencyParser.parse(_amountController.text);
    if (amount <= 0) return;

    // 1. Tạo Giao dịch mới
    final newTx = TransactionModel(
      id: 't_new_${DateTime.now().millisecondsSinceEpoch}',
      walletId: _selectedWallet.id,
      amount: amount,
      type: _selectedType,
      category: _selectedCategory,
      title: _titleController.text.trim(),
      date: DateTime.now(),
      createdAt: DateTime.now(),
    );

    // 2. Chèn vào mock data
    MockData.transactions.insert(0, newTx);

    // 3. Cập nhật số dư ví
    final walletIdx = MockData.wallets.indexWhere((w) => w.id == _selectedWallet.id);
    if (walletIdx != -1) {
      final w = MockData.wallets[walletIdx];
      final newBalance = _selectedType == TransactionType.income
          ? w.balance + amount
          : w.balance - amount;
      MockData.wallets[walletIdx] = w.copyWith(balance: newBalance);
    }

    // 4. Nếu là chi tiêu, tự động tính toán tiến trình các Active Challenges
    if (_selectedType == TransactionType.expense) {
      final activeChallenges = MockData.challenges
          .where((c) => !c.isCompleted && c.walletId == _selectedWallet.id)
          .toList();

      for (final challenge in activeChallenges) {
        // Kiểm tra xem danh mục giao dịch này có thuộc diện bị theo dõi của challenge không
        // (Nếu list categoryIds trống, coi như theo dõi toàn bộ danh mục của ví đó)
        final categoryMatch = challenge.categoryIds.isEmpty ||
            challenge.categoryIds.contains(_selectedCategory.name);

        if (categoryMatch) {
          final challengeIdx = MockData.challenges.indexOf(challenge);
          if (challengeIdx != -1) {
            int shields = challenge.shields;
            int violations = challenge.currentViolations;
            ChallengeStatus newStatus = challenge.status;
            bool wasProtected = false;

            final nextSpent = challenge.actualSpent + amount;
            if (nextSpent > challenge.spendLimit) {
              violations++;
              if (shields > 0) {
                shields--;
                wasProtected = true;
              } else {
                newStatus = ChallengeStatus.failed;
              }
            }

            final updatedChallenge = challenge.copyWith(
              actualSpent: nextSpent,
              shields: shields,
              currentViolations: violations,
              status: newStatus,
            );
            MockData.challenges[challengeIdx] = updatedChallenge;

            if (newStatus == ChallengeStatus.failed) {
              // Khấu trừ cược nếu là các thử thách mock mặc định (c3, c5) chưa bị trừ khi khởi tạo
              if (challenge.id == 'c3' || challenge.id == 'c5') {
                final betWalletIdx = MockData.wallets.indexWhere((w) => w.id == updatedChallenge.walletId);
                if (betWalletIdx != -1) {
                  final bw = MockData.wallets[betWalletIdx];
                  MockData.wallets[betWalletIdx] = bw.copyWith(
                    balance: bw.balance - updatedChallenge.betAmount,
                  );
                }
              }

              // Hiển thị thông báo nóng
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: AppColors.accent,
                  duration: const Duration(seconds: 4),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  content: Row(
                    children: [
                      const Text('🚨', style: TextStyle(fontSize: 24)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Vượt hạn mức! Thất bại thử thách "${updatedChallenge.title}". Bạn bị phạt mất ${NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0).format(updatedChallenge.betAmount)}!',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            } else if (wasProtected) {
              // Cảnh báo nhưng được khiên bảo vệ
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: AppColors.warning,
                  duration: const Duration(seconds: 5),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  content: Row(
                    children: [
                      const Text('🛡️', style: TextStyle(fontSize: 24)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Cảnh báo vượt hạn mức! Nhưng Tấm khiên bảo vệ đã cứu nguy cho bạn. Thử thách "${updatedChallenge.title}" vẫn an toàn. (Còn lại $shields Khiên)',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
          }
        }
      }
    }

    // 5. Callback để HomeScreen setState và đóng sheet
    widget.onSaved();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);

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
              // Thanh ngang nhỏ báo hiệu kéo được
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
                  Text(
                    'Ghi chép giao dịch',
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const Divider(height: 24),

              // Loại giao dịch
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(
                        child: Text(
                          'Chi tiêu (Expense)',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      selected: _selectedType == TransactionType.expense,
                      selectedColor: AppColors.accent.withValues(alpha: 0.15),
                      labelStyle: TextStyle(
                        color: _selectedType == TransactionType.expense ? AppColors.accent : AppColors.textMuted,
                      ),
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedType = TransactionType.expense;
                            _selectedCategory = TransactionCategory.food;
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(
                        child: Text(
                          'Thu nhập (Income)',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      selected: _selectedType == TransactionType.income,
                      selectedColor: AppColors.success.withValues(alpha: 0.15),
                      labelStyle: TextStyle(
                        color: _selectedType == TransactionType.income ? AppColors.success : AppColors.textMuted,
                      ),
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedType = TransactionType.income;
                            _selectedCategory = TransactionCategory.work;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Ví tài chính
              const Text(
                'Chọn Ví',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<WalletModel>(
                initialValue: _selectedWallet,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                dropdownColor: isDark ? AppColors.darkCard : Colors.white,
                items: MockData.wallets.map((wallet) {
                  return DropdownMenuItem<WalletModel>(
                    value: wallet,
                    child: Row(
                      children: [
                        Text(wallet.icon, style: const TextStyle(fontSize: 18)),
                        const SizedBox(width: 10),
                        Text(
                          '${wallet.name} (${formatter.format(wallet.balance)})',
                          style: TextStyle(
                            color: isDark ? Colors.white : AppColors.textOnLight,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _selectedWallet = val);
                  }
                },
              ),
              const SizedBox(height: 16),

              // Tên giao dịch
              const Text(
                'Tiêu đề / Nội dung',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  hintText: 'Ví dụ: Ăn trưa, Nhận lương, Mua sắm...',
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Vui lòng nhập tên giao dịch';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Số tiền
              const Text(
                'Số tiền (đ)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: false, signed: false),
                inputFormatters: [VndCurrencyInputFormatter()],
                decoration: const InputDecoration(
                  hintText: '0',
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Vui lòng nhập số tiền';
                  final parsed = CurrencyParser.parse(v);
                  if (parsed <= 0) return 'Số tiền không hợp lệ';
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Danh mục
              const Text(
                'Chọn Danh mục',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: TransactionCategory.values
                    .where((cat) => _selectedType == TransactionType.income
                        ? cat == TransactionCategory.work || cat == TransactionCategory.other
                        : cat != TransactionCategory.work)
                    .map((cat) {
                  final isSelected = _selectedCategory == cat;
                  
                  // Map icon & label
                  String icon = '📦';
                  String label = 'Khác';
                  switch (cat) {
                    case TransactionCategory.food:
                      icon = '🍜'; label = 'Ăn uống'; break;
                    case TransactionCategory.transport:
                      icon = '🚗'; label = 'Di chuyển'; break;
                    case TransactionCategory.shopping:
                      icon = '🛍️'; label = 'Mua sắm'; break;
                    case TransactionCategory.work:
                      icon = '💼'; label = 'Thu nhập'; break;
                    case TransactionCategory.health:
                      icon = '❤️‍🩹'; label = 'Sức khỏe'; break;
                    case TransactionCategory.entertainment:
                      icon = '🎮'; label = 'Giải trí'; break;
                    case TransactionCategory.other:
                      icon = '📦'; label = 'Khác'; break;
                  }

                  return ChoiceChip(
                    avatar: Text(icon),
                    label: Text(label),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedCategory = cat);
                      }
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 28),

              // Button hành động
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _save,
                  child: const Text(
                    'Lưu giao dịch',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

