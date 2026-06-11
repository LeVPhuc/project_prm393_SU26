import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
// Lưu ý: Đảm bảo bạn đã tạo file main_wrapper.dart và import vào đây
import 'screens/main_wrapper.dart';

void main() {
  runApp(const VunVenApp());
}

class VunVenApp extends StatelessWidget {
  const VunVenApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vun Vén',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00875A),
          primary: const Color(0xFF00875A),
          secondary: const Color(0xFF0D9488),
          surface: Colors.white,
        ),

        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(color: Colors.green),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00875A),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            minimumSize: const Size(double.infinity, 55),
          ),
        ),
        fontFamily: 'Roboto',
      ),

      // Màn hình khởi đầu vẫn là SplashScreen
      // Sau khi SplashScreen chạy xong, bạn sẽ dùng Navigator.pushReplacement
      // để điều hướng sang MainWrapper(userName: "Văn A")
      home: const SplashScreen(),
    );
  }
}