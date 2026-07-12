import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/brand_logo.dart';
import '../auth/login_screen.dart';
import '../main_navigation.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AppState _appState = AppState();
  bool _biometricEnabled = false;

  @override
  void initState() {
    super.initState();
    _appState.addListener(_refresh);
  }

  @override
  void dispose() {
    _appState.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() => setState(() {});

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor:
            Theme.of(context).brightness == Brightness.dark
                ? AppColors.darkSurface
                : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _appState.logout();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(),
          transitionsBuilder: (context, anim, secondaryAnimation, child) =>
              FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 500),
        ),
        (route) => false,
      );
    }
  }

  void _showEditProfileSheet() {
    final nameController = TextEditingController(text: _appState.userName);
    final emailController = TextEditingController(text: _appState.userEmail);
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            ),
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: AppColors.textMuted.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Chỉnh sửa hồ sơ',
                    style: Theme.of(ctx).textTheme.displayMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Họ và tên',
                      prefixIcon: Icon(Icons.person_outline_rounded),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Họ tên không được để trống';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Email không được để trống';
                      }
                      final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                      if (!regex.hasMatch(val.trim())) {
                        return 'Email không đúng định dạng';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        await _appState.updateProfile(
                          nameController.text.trim(),
                          emailController.text.trim(),
                        );
                        if (!ctx.mounted) return;
                        Navigator.of(ctx).pop();
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Cập nhật hồ sơ thành công!'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      }
                    },
                    child: const Text('Lưu thay đổi'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showSecuritySheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              ),
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: AppColors.textMuted.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Bảo mật',
                    style: Theme.of(ctx).textTheme.displayMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ListTile(
                    leading: const Icon(Icons.fingerprint_rounded, color: AppColors.primary),
                    title: const Text('Xác thực vân tay / Face ID'),
                    subtitle: const Text('Yêu cầu khi mở ứng dụng'),
                    trailing: Switch.adaptive(
                      value: _biometricEnabled,
                      activeThumbColor: AppColors.primary,
                      onChanged: (val) {
                        setState(() => _biometricEnabled = val);
                        setSheetState(() {});
                      },
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.lock_outline_rounded, color: AppColors.accent),
                    title: const Text('Đổi mật khẩu'),
                    subtitle: const Text('Thay đổi mật khẩu đăng nhập'),
                    trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
                    onTap: () {
                      Navigator.of(ctx).pop();
                      _showChangePasswordDialog();
                    },
                  ),
                ],
              ),
            );
          }
        );
      },
    );
  }

  void _showChangePasswordDialog() {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Đổi mật khẩu'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: oldPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Mật khẩu cũ',
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Vui lòng nhập mật khẩu cũ';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: newPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Mật khẩu mới',
                  ),
                  validator: (val) {
                    if (val == null || val.length < 6) return 'Mật khẩu mới tối thiểu 6 ký tự';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: confirmPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Xác nhận mật khẩu mới',
                  ),
                  validator: (val) {
                    if (val != newPasswordController.text) return 'Mật khẩu xác nhận không khớp';
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Đổi mật khẩu thành công!'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              },
              child: const Text('Đổi mật khẩu'),
            ),
          ],
        );
      },
    );
  }

  void _showBackupDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            bool isLoading = true;
            Future.delayed(const Duration(milliseconds: 1500), () {
              if (ctx.mounted) {
                setDialogState(() {
                  isLoading = false;
                });
              }
            });

            final isDark = Theme.of(ctx).brightness == Brightness.dark;
            final nowStr = DateFormat('HH:mm dd/MM/yyyy').format(DateTime.now());

            return AlertDialog(
              backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 16),
                  if (isLoading) ...[
                    const CircularProgressIndicator(color: AppColors.primary),
                    const SizedBox(height: 20),
                    const Text(
                      'Đang sao lưu dữ liệu...',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Đang mã hóa và đồng bộ lên đám mây bảo mật.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                    ),
                  ] else ...[
                    const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 64),
                    const SizedBox(height: 20),
                    const Text(
                      'Sao lưu thành công!',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Bản sao lưu gần nhất: $nowStr',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 13),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text('Đóng'),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showHelpSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          maxChildSize: 0.9,
          minChildSize: 0.5,
          expand: false,
          builder: (_, controller) {
            return Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              ),
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: AppColors.textMuted.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Trợ giúp & Hỗ trợ',
                    style: Theme.of(ctx).textTheme.displayMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView(
                      controller: controller,
                      children: [
                        _buildFaqItem(
                          'Vún Vén là gì?',
                          'Vún Vén là ứng dụng giúp bạn quản lý tài chính cá nhân thông qua việc theo dõi thu chi, lập kế hoạch tiết kiệm và tham gia các thử thách chi tiêu thông minh.',
                          isDark,
                        ),
                        _buildFaqItem(
                          'Quỹ đóng băng là gì?',
                          'Là khoản tiền bạn cam kết tiết kiệm cho một Thử thách cụ thể. Khi thử thách chưa hoàn thành hoặc chưa kết thúc hạn, số tiền này sẽ bị tạm khóa.',
                          isDark,
                        ),
                        _buildFaqItem(
                          'Làm thế nào để tăng cấp độ (Level)?',
                          'Bạn sẽ nhận được XP mỗi khi ghi nhận giao dịch, hoàn thành thử thách tiết kiệm hoặc duy trì chuỗi chi tiêu kỷ luật.',
                          isDark,
                        ),
                        const SizedBox(height: 20),
                        const Divider(),
                        const SizedBox(height: 16),
                        const Text(
                          'Liên hệ hỗ trợ',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 12),
                        const ListTile(
                          leading: Icon(Icons.email_outlined, color: AppColors.primary),
                          title: Text('support@vunven.vn'),
                          subtitle: Text('Thời gian phản hồi trong 24 giờ'),
                        ),
                        const ListTile(
                          leading: Icon(Icons.phone_in_talk_outlined, color: AppColors.primary),
                          title: Text('1900 8888 (Miễn phí)'),
                          subtitle: Text('Hỗ trợ 24/7'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFaqItem(String question, String answer, bool isDark) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Text(
              answer,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 13, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  void _showAboutSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.textMuted.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Center(
                child: BrandLogo(size: 64, showBackground: false),
              ),
              const SizedBox(height: 8),
              const Center(
                child: Text(
                  'Vún Vén',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
              const Center(
                child: Text(
                  'Ứng dụng tiết kiệm thông minh',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                ),
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 12),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Phiên bản', style: TextStyle(color: AppColors.textMuted)),
                  Text('1.0.0 (Build 42)', style: TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 8),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Bản quyền', style: TextStyle(color: AppColors.textMuted)),
                  Text('© 2026 Lê Văn Phúc', style: TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 8),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Công nghệ', style: TextStyle(color: AppColors.textMuted)),
                  Text('Flutter 3.x & Dart 3.x', style: TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Đóng'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final userName = _appState.userName;
    final userEmail = _appState.userEmail;
    final initial = userName.isNotEmpty ? userName[0].toUpperCase() : 'U';

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
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
            backgroundColor: const Color(0xFF0F172A),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 16),
                      // Avatar
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.primary, AppColors.secondary],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.5),
                              blurRadius: 20,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            initial,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        userName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        userEmail.isNotEmpty ? userEmail : 'Chưa cập nhật email',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Settings sections
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
              child: Text(
                'Cài đặt',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: _SettingsSection(
              isDark: isDark,
              children: [
                // Dark mode toggle
                _SettingsTile(
                  icon: _appState.isDarkMode
                      ? Icons.dark_mode_rounded
                      : Icons.light_mode_rounded,
                  iconColor: _appState.isDarkMode
                      ? AppColors.secondary
                      : AppColors.warning,
                  title: 'Chế độ tối',
                  subtitle: _appState.isDarkMode ? 'Đang bật' : 'Đang tắt',
                  trailing: Switch.adaptive(
                    value: _appState.isDarkMode,
                    onChanged: (_) => _appState.toggleTheme(),
                    activeThumbColor: AppColors.primary,
                  ),
                  isDark: isDark,
                ),
                _SettingsTile(
                  icon: Icons.notifications_outlined,
                  iconColor: AppColors.accent,
                  title: 'Thông báo',
                  subtitle: _appState.notificationsEnabled ? 'Đang bật' : 'Đang tắt',
                  trailing: Switch.adaptive(
                    value: _appState.notificationsEnabled,
                    onChanged: (val) => _appState.toggleNotifications(val),
                    activeThumbColor: AppColors.primary,
                  ),
                  isDark: isDark,
                ),
              ],
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: Text(
                'Tài khoản',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: _SettingsSection(
              isDark: isDark,
              children: [
                _SettingsTile(
                  icon: Icons.person_outline_rounded,
                  iconColor: AppColors.primary,
                  title: 'Chỉnh sửa hồ sơ',
                  subtitle: 'Cập nhật thông tin cá nhân',
                  trailing: const Icon(Icons.chevron_right_rounded,
                      color: AppColors.textMuted),
                  isDark: isDark,
                  onTap: _showEditProfileSheet,
                ),
                _SettingsTile(
                  icon: Icons.security_rounded,
                  iconColor: AppColors.success,
                  title: 'Bảo mật',
                  subtitle: 'Đổi mật khẩu, khóa vân tay',
                  trailing: const Icon(Icons.chevron_right_rounded,
                      color: AppColors.textMuted),
                  isDark: isDark,
                  onTap: _showSecuritySheet,
                ),
                _SettingsTile(
                  icon: Icons.backup_rounded,
                  iconColor: AppColors.secondary,
                  title: 'Sao lưu dữ liệu',
                  subtitle: 'Đồng bộ dữ liệu lên cloud',
                  trailing: const Icon(Icons.chevron_right_rounded,
                      color: AppColors.textMuted),
                  isDark: isDark,
                  onTap: _showBackupDialog,
                ),
              ],
            ),
          ),

          // About section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: Text(
                'Khác',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: _SettingsSection(
              isDark: isDark,
              children: [
                _SettingsTile(
                  icon: Icons.help_outline_rounded,
                  iconColor: AppColors.textSecondary,
                  title: 'Trợ giúp & Hỗ trợ',
                  subtitle: 'FAQ, liên hệ chúng tôi',
                  trailing: const Icon(Icons.chevron_right_rounded,
                      color: AppColors.textMuted),
                  isDark: isDark,
                  onTap: _showHelpSheet,
                ),
                _SettingsTile(
                  icon: Icons.info_outline_rounded,
                  iconColor: AppColors.textSecondary,
                  title: 'Về ứng dụng',
                  subtitle: 'Vún Vén v1.0.0',
                  trailing: const Icon(Icons.chevron_right_rounded,
                      color: AppColors.textMuted),
                  isDark: isDark,
                  onTap: _showAboutSheet,
                ),
              ],
            ),
          ),

          // Logout button
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _logout,
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text('Đăng xuất'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent.withValues(alpha: 0.12),
                    foregroundColor: AppColors.accent,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: AppColors.accent.withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final List<Widget> children;
  final bool isDark;

  const _SettingsSection({required this.children, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
        child: Column(
          children: List.generate(
            children.length,
            (i) => Column(
              children: [
                children[i],
                if (i < children.length - 1)
                  Divider(
                    height: 1,
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    indent: 68,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Widget trailing;
  final bool isDark;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.isDark,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}
