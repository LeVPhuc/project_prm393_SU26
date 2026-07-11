import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../models/wallet_model.dart';
import '../../services/mock_data.dart';
import '../../theme/app_theme.dart';
import '../main_navigation.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  static const List<List<Color>> _walletGradients = [
    [Color(0xFF0D9488), Color(0xFF0F766E)],
    [Color(0xFF4F46E5), Color(0xFF3B37BB)],
    [Color(0xFFF43F5E), Color(0xFFBE123C)],
    [Color(0xFFF59E0B), Color(0xFFB45309)],
  ];

  void _showAddWalletSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _WalletFormSheet(
        onSaved: () {
          setState(() {});
        },
      ),
    );
  }

  void _showWalletActionSheet(BuildContext context, WalletModel wallet) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
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
          padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
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
                children: [
                  Text(wallet.icon, style: const TextStyle(fontSize: 32)),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          wallet.name,
                          style: Theme.of(context).textTheme.displayMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.darkCard : AppColors.lightCard,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                wallet.type,
                                style: TextStyle(
                                  color: isDark ? Colors.white70 : Colors.black87,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            if (wallet.isDefault) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'Mặc định',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const Divider(height: 28),
              
              // Wallet info summary
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Số dư hiện tại:',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 14),
                  ),
                  Text(
                    formatter.format(wallet.balance),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryLight,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Action list
              if (!wallet.isDefault)
                ListTile(
                  leading: const Icon(Icons.star_rounded, color: AppColors.warning),
                  title: const Text('Đặt làm ví mặc định'),
                  subtitle: const Text('Sử dụng ví này làm ví giao dịch ưu tiên'),
                  onTap: () {
                    Navigator.pop(context);
                    _setDefaultWallet(wallet);
                  },
                ),
              ListTile(
                leading: const Icon(Icons.edit_rounded, color: AppColors.primary),
                title: const Text('Chỉnh sửa ví'),
                subtitle: const Text('Thay đổi tên, số dư, icon hoặc loại ví'),
                onTap: () {
                  Navigator.pop(context);
                  _showEditWalletSheet(context, wallet);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_rounded, color: AppColors.accent),
                title: const Text('Xóa ví'),
                subtitle: const Text('Xóa ví này và tất cả lịch sử giao dịch liên quan'),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDeleteWallet(context, wallet);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _setDefaultWallet(WalletModel wallet) {
    setState(() {
      for (int i = 0; i < MockData.wallets.length; i++) {
        MockData.wallets[i] = MockData.wallets[i].copyWith(
          isDefault: MockData.wallets[i].id == wallet.id,
        );
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.success,
        content: Text('⭐ Đã đặt ví "${wallet.name}" làm ví giao dịch mặc định.'),
      ),
    );
  }

  void _showEditWalletSheet(BuildContext context, WalletModel wallet) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _WalletFormSheet(
        walletToEdit: wallet,
        onSaved: () {
          setState(() {});
        },
      ),
    );
  }

  void _confirmDeleteWallet(BuildContext context, WalletModel wallet) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (MockData.wallets.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.accent,
          content: Text('⚠️ Bạn không thể xóa ví cuối cùng! Hãy tạo một ví mới trước khi xóa ví này.'),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: isDark ? AppColors.darkCard : Colors.white,
          title: const Text('Xác nhận xóa ví?'),
          content: Text(
            'Bạn có chắc chắn muốn xóa ví "${wallet.name}"?\n\nHành động này cũng sẽ xóa tất cả giao dịch liên quan đến ví này và không thể hoàn tác.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
              onPressed: () {
                setState(() {
                  // Delete wallet
                  MockData.wallets.removeWhere((w) => w.id == wallet.id);
                  // Delete associated transactions
                  MockData.transactions.removeWhere((t) => t.walletId == wallet.id);
                  
                  // If we deleted the default wallet, make another one default
                  if (wallet.isDefault && MockData.wallets.isNotEmpty) {
                    MockData.wallets[0] = MockData.wallets[0].copyWith(isDefault: true);
                  }
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: AppColors.accent,
                    content: Text('🗑️ Đã xóa ví "${wallet.name}" và các giao dịch liên quan.'),
                  ),
                );
              },
              child: const Text('Xóa', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 160,
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
            backgroundColor: const Color(0xFF0D4F47),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF0F172A), Color(0xFF0D4F47), Color(0xFF0D9488)],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Text('💼', style: TextStyle(fontSize: 28)),
                            SizedBox(width: 10),
                            Text(
                              'Ví tiền',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Tổng tài sản',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.65),
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          formatter.format(MockData.totalBalance),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Add wallet button
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
              child: ElevatedButton.icon(
                onPressed: () => _showAddWalletSheet(context),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Thêm ví mới'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 4),
              child: Text(
                'Danh sách ví',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
          ),

          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final wallet = MockData.wallets[index];
                final gradient = _walletGradients[wallet.colorIndex % _walletGradients.length];
                return GestureDetector(
                  onTap: () => _showWalletActionSheet(context, wallet),
                  child: _WalletCard(
                    wallet: wallet,
                    gradient: gradient,
                    formatter: formatter,
                    isDark: isDark,
                  ),
                );
              },
              childCount: MockData.wallets.length,
            ),
          ),

          // Recent Transactions per wallet
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
              child: Text(
                'Giao dịch theo ví',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
          ),

          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final wallet = MockData.wallets[index];
                final walletTxs = MockData.transactions
                    .where((t) => t.walletId == wallet.id)
                    .take(3)
                    .toList();

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(wallet.icon, style: const TextStyle(fontSize: 18)),
                            const SizedBox(width: 8),
                            Text(
                              wallet.name,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const Spacer(),
                            Text(
                              '${walletTxs.length} giao dịch gần đây',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                        if (walletTxs.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          ...walletTxs.map((tx) => Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  children: [
                                    Text(tx.categoryIcon, style: const TextStyle(fontSize: 16)),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        tx.title,
                                        style: Theme.of(context).textTheme.bodyMedium,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Text(
                                      (tx.type.name == 'income' ? '+' : '-') + formatter.format(tx.amount),
                                      style: TextStyle(
                                        color: tx.type.name == 'income'
                                            ? AppColors.success
                                            : AppColors.accent,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                        ] else ...[
                          const SizedBox(height: 8),
                          Text(
                            'Chưa có giao dịch nào trong ví này',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
              childCount: MockData.wallets.length,
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

class _WalletCard extends StatelessWidget {
  final Wallet wallet;
  final List<Color> gradient;
  final NumberFormat formatter;
  final bool isDark;

  const _WalletCard({
    required this.wallet,
    required this.gradient,
    required this.formatter,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
      child: Container(
        height: 130,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradient,
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: gradient.first.withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Decorative circles
            Positioned(
              right: -20,
              top: -20,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
            ),
            Positioned(
              right: 30,
              bottom: -30,
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.05),
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(wallet.icon, style: const TextStyle(fontSize: 24)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Row(
                          children: [
                            Text(
                              wallet.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (wallet.isDefault) ...[
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.star_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
                            ],
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          wallet.type,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    formatter.format(wallet.balance),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// WALLET ADD/EDIT FORM SHEET
// ─────────────────────────────────────────────────────────────
class _WalletFormSheet extends StatefulWidget {
  final WalletModel? walletToEdit;
  final VoidCallback onSaved;

  const _WalletFormSheet({
    this.walletToEdit,
    required this.onSaved,
  });

  @override
  State<_WalletFormSheet> createState() => _WalletFormSheetState();
}

class _WalletFormSheetState extends State<_WalletFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _balanceController;
  
  late String _selectedType;
  late String _selectedEmoji;
  late int _selectedColorIndex;

  final List<String> _emojis = ['💵', '🏦', '📱', '💳', '🐷', '💰', '🪙', '💼', '🔑', '📈'];
  final List<String> _types = ['Tiền mặt', 'Ngân hàng', 'Ví điện tử'];
  
  static const List<List<Color>> _walletGradients = [
    [Color(0xFF0D9488), Color(0xFF0F766E)],
    [Color(0xFF4F46E5), Color(0xFF3B37BB)],
    [Color(0xFFF43F5E), Color(0xFFBE123C)],
    [Color(0xFFF59E0B), Color(0xFFB45309)],
  ];

  @override
  void initState() {
    super.initState();
    final editWallet = widget.walletToEdit;
    
    _nameController = TextEditingController(text: editWallet?.name ?? '');
    _balanceController = TextEditingController(
      text: editWallet != null ? editWallet.balance.toStringAsFixed(0) : '',
    );
    
    _selectedType = editWallet?.type ?? 'Tiền mặt';
    _selectedEmoji = editWallet?.icon ?? '💵';
    _selectedColorIndex = editWallet?.colorIndex ?? 0;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final balance = double.tryParse(_balanceController.text.trim()) ?? 0.0;
    final editWallet = widget.walletToEdit;

    if (editWallet != null) {
      // Edit mode: find index and replace
      final idx = MockData.wallets.indexWhere((w) => w.id == editWallet.id);
      if (idx != -1) {
        MockData.wallets[idx] = editWallet.copyWith(
          name: name,
          balance: balance,
          type: _selectedType,
          icon: _selectedEmoji,
          colorIndex: _selectedColorIndex,
          updatedAt: DateTime.now(),
        );
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.success,
          content: Text('💾 Đã cập nhật ví "$name" thành công!'),
        ),
      );
    } else {
      // Add mode: create new
      final newWallet = WalletModel(
        id: 'w_new_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        balance: balance,
        type: _selectedType,
        icon: _selectedEmoji,
        colorIndex: _selectedColorIndex,
        isDefault: MockData.wallets.isEmpty, // Make default if it's the first wallet
        updatedAt: DateTime.now(),
      );
      MockData.wallets.add(newWallet);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.success,
          content: Text('🎉 Đã tạo ví "$name" thành công!'),
        ),
      );
    }

    widget.onSaved();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEdit = widget.walletToEdit != null;

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
                  Text(
                    isEdit ? 'Chỉnh sửa ví' : 'Thêm ví mới',
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const Divider(height: 20),

              // Wallet Name
              const Text('Tên ví / Tài khoản', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(hintText: 'Ví dụ: Vietcombank, Momo, Tiền mặt...'),
                validator: (v) => (v == null || v.isEmpty) ? 'Vui lòng nhập tên ví' : null,
              ),
              const SizedBox(height: 16),

              // Initial Balance
              const Text('Số dư hiện tại (đ)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _balanceController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(hintText: '0'),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Vui lòng nhập số dư';
                  if (double.tryParse(v) == null) return 'Số dư không hợp lệ';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Wallet Type Dropdown
              const Text('Loại ví', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                initialValue: _selectedType,
                dropdownColor: isDark ? AppColors.darkCard : Colors.white,
                decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
                items: _types.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _selectedType = val);
                  }
                },
              ),
              const SizedBox(height: 16),

              // Color Index (Gradient) Selector
              const Text('Màu sắc thẻ ví', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 8),
              Row(
                children: List.generate(_walletGradients.length, (idx) {
                  final gradient = _walletGradients[idx];
                  final isSelected = _selectedColorIndex == idx;
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: InkWell(
                      onTap: () => setState(() => _selectedColorIndex = idx),
                      borderRadius: BorderRadius.circular(100),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: gradient,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          border: isSelected
                              ? Border.all(
                                  color: isDark ? Colors.white : Colors.black87,
                                  width: 3.0,
                                )
                              : null,
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: gradient.first.withValues(alpha: 0.4),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  )
                                ]
                              : null,
                        ),
                        child: isSelected
                            ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 20,
                              )
                            : null,
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),

              // Emoji/Icon Selector
              const Text('Biểu tượng đại diện', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
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

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _save,
                  child: Text(
                    isEdit ? 'Lưu thay đổi' : 'Tạo ví mới',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
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
