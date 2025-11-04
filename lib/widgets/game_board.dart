import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/game_level.dart';
import '../../widgets/card_widget.dart';

class GameBoard extends StatelessWidget {
  final VoidCallback onLevelComplete;
  const GameBoard({super.key, required this.onLevelComplete});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Consumer<GameLevel>(
        builder: (context, game, child) {
          if (game.isLevelComplete()) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted) onLevelComplete();
            });
          }

          const crossAxis = 4;
          return LayoutBuilder(
            builder: (context, constraints) {
              const spacing = 8.0;
              final totalHSpacing = spacing * (crossAxis + 1);
              final availableWidth = constraints.maxWidth - totalHSpacing;
              final cardWidth = availableWidth / crossAxis;

              final rows = (game.cards.length / crossAxis).ceil();
              final totalVSpacing = spacing * (rows + 1);
              final availableHeight = constraints.maxHeight - totalVSpacing;
              final cardHeight =
                  rows > 0 ? (availableHeight / rows) : cardWidth * 1.5;

              final aspectRatio = cardWidth / cardHeight;

              return GridView.builder(
                padding: const EdgeInsets.all(spacing),
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxis,
                  crossAxisSpacing: spacing,
                  mainAxisSpacing: spacing,
                  childAspectRatio: aspectRatio,
                ),
                itemCount: game.cards.length,
                itemBuilder: (context, index) => CardWidget(
                  card: game.cards[index],
                  onTap: () => game.onCardTapped(game.cards[index]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
