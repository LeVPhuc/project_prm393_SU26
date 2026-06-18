import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/challenge_model.dart';

final challengeProvider =
StateNotifierProvider<ChallengeNotifier,
    List<ChallengeModel>>((ref) {
  return ChallengeNotifier();
});

class ChallengeNotifier
    extends StateNotifier<List<ChallengeModel>> {

  ChallengeNotifier() : super([]);

  void addChallenge(
      ChallengeModel challenge) {

    state = [...state, challenge];
  }

  void deleteChallenge(int id) {

    state =
        state.where((e) => e.id != id).toList();
  }

  void updateAmount(
      int challengeId,
      double amount) {

    state = state.map((challenge) {

      if (challenge.id == challengeId) {

        return challenge.copyWith(
          currentAmount:
          challenge.currentAmount + amount,
        );
      }

      return challenge;
    }).toList();
  }
}