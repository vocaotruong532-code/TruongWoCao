
import 'package:flutter/material.dart';
import '../models/game_level.dart';
// thanh trợ giúp
class HelpBar extends StatelessWidget {
  final GameLevel level;

  const HelpBar({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.add_alarm),
              label: const Text("+10s"),
              onPressed: level.canUseHelp ? level.helpAddTime : null,
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.visibility),
              label: const Text("Xem 3s"),
              onPressed: level.canUseHelp ? level.helpRevealAll : null,
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.delete_forever),
              label: const Text("Xóa bomb"),
              onPressed: (level.canUseHelp && level.level >= 4)
                  ? level.helpRemoveBomb
                  : null,
            ),
          ],
        ),
        Text("Trợ giúp đã dùng: ${level.helpUsed}/${level.helpLimit}"),
      ],
    );
  }
}
