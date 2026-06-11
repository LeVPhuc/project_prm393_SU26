import 'package:flutter/material.dart';
import '../screens/dashboard_screen.dart';
import '../screens/account_screen.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;

  const CustomBottomNav({Key? key, required this.currentIndex}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: const Color(0xFF1E1E1E),
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(context, Icons.home, "Trang chủ", 0, () {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => DashboardScreen(userName: "Văn A")));
          }),
          _navItem(context, Icons.bar_chart, "Giao dịch", 1, () {}),
          const SizedBox(width: 40), // Khoảng trống cho FAB
          _navItem(context, Icons.pie_chart, "Ngân sách", 3, () {}),
          _navItem(context, Icons.person, "Tài khoản", 4, () {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AccountScreen(userName: "Văn A")));
          }),
        ],
      ),
    );
  }

  Widget _navItem(BuildContext context, IconData icon, String label, int index, VoidCallback onTap) {
    return IconButton(
      icon: Icon(icon, color: currentIndex == index ? const Color(0xFF00875A) : Colors.grey),
      onPressed: onTap,
    );
  }
}