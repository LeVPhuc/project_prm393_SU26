import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../core/constants/app_colors.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() =>
      _OnboardingScreenState();
}

class _OnboardingScreenState
    extends State<OnboardingScreen> {

  final controller = PageController();

  int currentPage = 0;

  final pages = [
    {
      "title": "Kiểm soát chi tiêu",
      "desc":
      "Theo dõi mọi khoản thu chi dễ dàng."
    },
    {
      "title": "Thách Đấu Với Chính Mình",
      "desc":
      "Biến tiết kiệm thành trò chơi."
    },
    {
      "title": "Xây dựng thói quen tài chính",
      "desc":
      "Tiết kiệm đều đặn mỗi ngày."
    },
  ];

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [

            Expanded(
              child: PageView.builder(
                controller: controller,

                itemCount: pages.length,

                onPageChanged: (value) {
                  setState(() {
                    currentPage = value;
                  });
                },

                itemBuilder: (context, index) {

                  return Padding(
                    padding:
                    const EdgeInsets.all(24),

                    child: Column(
                      mainAxisAlignment:
                      MainAxisAlignment.center,

                      children: [

                        Icon(
                          index == 0
                              ? Icons.account_balance_wallet
                              : index == 1
                              ? Icons.emoji_events
                              : Icons.savings,

                          size: 150,

                          color:
                          AppColors.primary,
                        ),

                        const SizedBox(height: 40),

                        Text(
                          pages[index]["title"]!,
                          textAlign:
                          TextAlign.center,

                          style:
                          const TextStyle(
                            fontSize: 28,
                            fontWeight:
                            FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 16),

                        Text(
                          pages[index]["desc"]!,
                          textAlign:
                          TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            SmoothPageIndicator(
              controller: controller,
              count: 3,
              effect: WormEffect(
                dotColor: Colors.grey,
                activeDotColor:
                AppColors.primary,
              ),
            ),

            const SizedBox(height: 24),

            Padding(
              padding:
              const EdgeInsets.all(24),

              child: SizedBox(
                width: double.infinity,

                height: 55,

                child: ElevatedButton(
                  onPressed: () {

                    if (currentPage == 2) {
                      context.go('/login');
                    } else {
                      controller.nextPage(
                        duration: const Duration(
                          milliseconds: 400,
                        ),
                        curve: Curves.ease,
                      );
                    }
                  },

                  child: Text(
                    currentPage == 2
                        ? "Bắt đầu ngay"
                        : "Tiếp tục",
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}