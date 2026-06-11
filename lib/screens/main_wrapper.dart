import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'transaction_screen.dart';
import 'account_screen.dart';

class MainWrapper extends StatefulWidget {
  final String userName;
  const MainWrapper({Key? key, required this.userName}) : super(key: key);

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Các màn hình con (không cần Scaffold nữa, hoặc nếu có thì không được có BottomNav)
    final List<Widget> pages = [
      DashboardScreen(userName: widget.userName),
      TransactionScreen(userName: widget.userName),
      const SizedBox(), // Chỗ trống cho FAB
      Container(child: const Center(child: Text("Ngân sách", style: TextStyle(color: Colors.white)))), // Placeholder
      AccountScreen(userName: widget.userName),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: pages[_currentIndex], // Chỉ hiển thị nội dung màn hình con
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF00875A),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: const Color(0xFF1E1E1E),
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navIcon(Icons.home, 0),
            _navIcon(Icons.bar_chart, 1),
            const SizedBox(width: 40),
            _navIcon(Icons.pie_chart, 3),
            _navIcon(Icons.person, 4),
          ],
        ),
      ),
    );
  }

  Widget _navIcon(IconData icon, int index) => IconButton(
    icon: Icon(icon, color: _currentIndex == index ? const Color(0xFF00875A) : Colors.grey),
    onPressed: () => setState(() => _currentIndex = index),
  );
}