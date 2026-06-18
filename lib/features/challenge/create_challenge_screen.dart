import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/challenge_model.dart';
import '../../providers/challenge_provider.dart';

class CreateChallengeScreen
    extends ConsumerStatefulWidget {

  const CreateChallengeScreen({super.key});

  @override
  ConsumerState<CreateChallengeScreen>
  createState() =>
      _CreateChallengeScreenState();
}

class _CreateChallengeScreenState
    extends ConsumerState<CreateChallengeScreen> {

  final titleController =
  TextEditingController();

  final targetController =
  TextEditingController();

  final freezeController =
  TextEditingController();

  int days = 7;

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title:
        const Text("Tạo thử thách"),
      ),

      body: Padding(
        padding:
        const EdgeInsets.all(16),

        child: Column(

          children: [

            TextField(
              controller: titleController,
              decoration:
              const InputDecoration(
                labelText:
                "Tên thử thách",
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller:
              targetController,
              keyboardType:
              TextInputType.number,

              decoration:
              const InputDecoration(
                labelText:
                "Mục tiêu chi tiêu",
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller:
              freezeController,

              keyboardType:
              TextInputType.number,

              decoration:
              const InputDecoration(
                labelText:
                "Tiền đóng băng",
              ),
            ),

            const SizedBox(height: 20),

            DropdownButton<int>(
              value: days,

              items: const [

                DropdownMenuItem(
                  value: 7,
                  child: Text("7 ngày"),
                ),

                DropdownMenuItem(
                  value: 14,
                  child: Text("14 ngày"),
                ),

                DropdownMenuItem(
                  value: 30,
                  child: Text("30 ngày"),
                ),
              ],

              onChanged: (value) {

                setState(() {
                  days = value!;
                });
              },
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: () {

                final challenge =
                ChallengeModel(

                  id: DateTime.now()
                      .millisecondsSinceEpoch,

                  title:
                  titleController.text,

                  targetAmount:
                  double.parse(
                    targetController
                        .text,
                  ),

                  currentAmount: 0,

                  freezeMoney:
                  double.parse(
                    freezeController
                        .text,
                  ),

                  startDate:
                  DateTime.now(),

                  endDate:
                  DateTime.now()
                      .add(
                    Duration(
                        days: days),
                  ),

                  status: "active",
                );

                ref
                    .read(
                    challengeProvider
                        .notifier)
                    .addChallenge(
                    challenge);

                Navigator.pop(context);
              },

              child:
              const Text("Bắt đầu"),
            )
          ],
        ),
      ),
    );
  }
}