import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: SafeArea(

        child: SingleChildScrollView(

          padding: const EdgeInsets.all(16),

          child: Column(

            crossAxisAlignment:
            CrossAxisAlignment.start,

            children: [

              const Row(
                mainAxisAlignment:
                MainAxisAlignment.spaceBetween,

                children: [

                  Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,

                    children: [

                      Text(
                        "Xin chào, Phúc 👋",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),

                      Text(
                        "Chúc bạn một ngày tốt lành",
                      ),
                    ],
                  ),

                  CircleAvatar(
                    radius: 25,
                  ),
                ],
              ),

              const SizedBox(height: 20),

              _buildBalanceCard(),

              const SizedBox(height: 20),

              _buildChallengeCard(),

              const SizedBox(height: 20),

              _buildQuickAction(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceCard() {

    return Container(
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.circular(20),
      ),

      child: const Column(

        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [

          Text(
            "Tổng tài sản",
            style: TextStyle(
              color: Colors.white,
            ),
          ),

          SizedBox(height: 10),

          Text(
            "12.500.000 đ",
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChallengeCard() {

    return Card(

      child: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(

          crossAxisAlignment:
          CrossAxisAlignment.start,

          children: [

            const Text(
              "Thử thách hiện tại",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              "Không ăn ngoài 7 ngày",
            ),

            const SizedBox(height: 10),

            LinearProgressIndicator(
              value: 0.6,
              borderRadius:
              BorderRadius.circular(10),
            ),

            const SizedBox(height: 10),

            const Text(
              "250.000đ / 500.000đ",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction() {

    return Row(

      mainAxisAlignment:
      MainAxisAlignment.spaceBetween,

      children: [

        _action(Icons.add, "Giao dịch"),
        _action(Icons.flag, "Challenge"),
        _action(Icons.bar_chart, "Stats"),
        _action(Icons.lock, "Quỹ"),
      ],
    );
  }

  Widget _action(
      IconData icon,
      String title,
      ) {

    return Column(
      children: [

        CircleAvatar(
          radius: 28,
          child: Icon(icon),
        ),

        const SizedBox(height: 6),

        Text(title),
      ],
    );
  }
}