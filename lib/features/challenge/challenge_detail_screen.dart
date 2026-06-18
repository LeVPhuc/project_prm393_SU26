import 'package:flutter/material.dart';

import '../../data/models/challenge_model.dart';

class ChallengeDetailScreen
    extends StatelessWidget {

  final ChallengeModel challenge;

  const ChallengeDetailScreen({
    super.key,
    required this.challenge,
  });

  @override
  Widget build(BuildContext context) {

    double progress =
        challenge.currentAmount /
            challenge.targetAmount;

    if (progress > 1) {
      progress = 1;
    }

    return Scaffold(

      appBar: AppBar(
        title:
        const Text("Chi tiết"),
      ),

      body: Padding(
        padding:
        const EdgeInsets.all(16),

        child: Column(

          crossAxisAlignment:
          CrossAxisAlignment.start,

          children: [

            Text(
              challenge.title,

              style:
              const TextStyle(
                fontSize: 24,
                fontWeight:
                FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            Text(
              "Đã chi: ${challenge.currentAmount.toStringAsFixed(0)}đ",
            ),

            Text(
              "Mục tiêu: ${challenge.targetAmount.toStringAsFixed(0)}đ",
            ),

            Text(
              "Đóng băng: ${challenge.freezeMoney.toStringAsFixed(0)}đ",
            ),

            const SizedBox(height: 20),

            LinearProgressIndicator(
              value: progress,
            ),
          ],
        ),
      ),
    );
  }
}