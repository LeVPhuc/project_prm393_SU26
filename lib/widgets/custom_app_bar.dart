// Ví dụ tạo một Custom AppBar
class MyCustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  const MyCustomAppBar({required this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(title: Text(title), backgroundColor: Colors.green);
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}