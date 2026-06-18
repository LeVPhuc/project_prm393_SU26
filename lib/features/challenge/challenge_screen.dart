import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/challenge_provider.dart';
import '../../widgets/challenge_card.dart';
import 'challenge_detail_screen.dart';
import 'create_challenge_screen.dart';

class ChallengeScreen
    extends ConsumerWidget {

  const ChallengeScreen({super.key});

  @override
  Widget build(
      BuildContext context,
      WidgetRef ref,
      ) {

    final challenges =
    ref.watch(challengeProvider);

    return Scaffold(

      appBar: AppBar(
        title: const Text(
          "Thách Đấu Với Chính Mình",
        ),
      ),

      floatingActionButton:
      FloatingActionButton(

        onPressed: () {

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
              const CreateChallengeScreen(),
            ),
          );
        },

        child: const Icon(Icons.add),
      ),

      body: challenges.isEmpty
          ? const Center(
        child:
        Text("Chưa có thử thách"),
      )
          : ListView.builder(
        padding:
        const EdgeInsets.all(16),

        itemCount:
        challenges.length,

        itemBuilder:
            (context, index) {

          final challenge =
          challenges[index];

          return ChallengeCard(

            challenge: challenge,

            onTap: () {

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      ChallengeDetailScreen(
                        challenge:
                        challenge,
                      ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}