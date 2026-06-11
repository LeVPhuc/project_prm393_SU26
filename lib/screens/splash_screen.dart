import 'package:flutter/material.dart';
import 'main_wrapper.dart'; // Import MainWrapper thay vì WelcomeScreen

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Giữ nguyên delay 3 giây
    Future.delayed(const Duration(seconds: 3), () {
      // Chuyển hướng đến MainWrapper
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const MainWrapper(userName: "Văn A"), // Thay thế WelcomeScreen
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF10B981),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Đảm bảo file ảnh tồn tại ở đường dẫn assets/images/logo_vun_ven.png
            Image.asset('assets/images/logo_vun_ven.png', width: 150),
            const SizedBox(height: 20),
            const Text(
              'Vun Vén',
              style: TextStyle(
                  fontSize: 45,
                  fontWeight: FontWeight.bold,
                  color: Colors.white
              ),
            ),
          ],
        ),
      ),
    );
  }
}