import 'package:flutter/material.dart';

import '../data/models/challenge_model.dart';

class ChallengeCard extends StatelessWidget {

  final ChallengeModel challenge;

  final VoidCallback onTap;

  const ChallengeCard({
    super.key,
    required this.challenge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {

    double progress =
        challenge.currentAmount /
            challenge.targetAmount;

    if (progress > 1) {
      progress = 1;
    }

    return Card(
      margin:
      const EdgeInsets.only(bottom: 12),

      child: InkWell(
        onTap: onTap,

        child: Padding(
          padding:
          const EdgeInsets.all(16),

          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,

            children: [

              Text(
                challenge.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight:
                  FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              LinearProgressIndicator(
                value: progress,
              ),

              const SizedBox(height: 10),

              Text(
                "${challenge.currentAmount.toStringAsFixed(0)}đ / ${challenge.targetAmount.toStringAsFixed(0)}đ",
              ),
            ],
          ),
        ),
      ),
    );
  }
}