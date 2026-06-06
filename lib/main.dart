import 'package:flutter/material.dart';
import 'screens/splash_screen.dart'; // Đảm bảo đường dẫn này khớp với cấu trúc thư mục của bạn

void main() {
  runApp(const VunVenApp());
}

class VunVenApp extends StatelessWidget {
  const VunVenApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vun Vén',
      debugShowCheckedModeBanner: false, // Tắt biểu tượng chữ "DEBUG" ở góc phải màn hình

      // Cấu hình giao diện và màu sắc chủ đạo cho toàn bộ ứng dụng
      theme: ThemeData(
        useMaterial3: true, // Kích hoạt Material 3 mới nhất giúp giao diện mượt mà và hiện đại

        // Định nghĩa bộ màu sắc đồng bộ với thiết kế Figma của Vun Vén
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF10B981), // Màu xanh lá gốc của ứng dụng
          primary: const Color(0xFF10B981),   // Màu chủ đạo (Dùng cho nút bấm chính, thanh tiêu đề)
          secondary: const Color(0xFF0D9488), // Màu xanh Deep Teal (Dùng cho các thành phần phụ)
          background: const Color(0xFFF8FAFC), // Màu nền xám trắng dịu mắt cho các màn hình
        ),

        // Cấu hình phông chữ mặc định nếu cần (sau này bạn có thể bổ sung font Poppins hoặc Lato)
        fontFamily: 'Roboto',
      ),

      // Khai báo màn hình đầu tiên xuất hiện khi mở ứng dụng lên là Màn hình chào
      home: const SplashScreen(),
    );
  }
}