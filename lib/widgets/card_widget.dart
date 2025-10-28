import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/card_model.dart';
import '../providers/sound_provider.dart';
import 'card_front.dart';
import 'card_back.dart';
import 'card_effects.dart'; // ✅ import hiệu ứng

class CardWidget extends StatefulWidget {
  final CardModel card;
  final VoidCallback? onTap;

  const CardWidget({super.key, required this.card, this.onTap});

  @override
  State<CardWidget> createState() => _CardWidgetState();
}

class _CardWidgetState extends State<CardWidget> with TickerProviderStateMixin {
  late final CardEffects _effects;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _effects = CardEffects(this);

    if (widget.card.isFlipped) _effects.flipController.value = 1;
  }

  @override
  void didUpdateWidget(covariant CardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _effects.syncFlip(widget.card.isFlipped);
  }

  @override
  Widget build(BuildContext context) {
    final sound = Provider.of<SoundProvider>(context, listen: false);
    if (widget.card.isMatched) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () {
        if (!widget.card.isFlipped && !widget.card.isMatched) {
          sound.playFlip();
          _effects.playShake();
          widget.onTap?.call();
        }
      },
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _effects.flipAnimation,
          _effects.shakeAnimation,
          _effects.moveAnimation
        ]),
        builder: (context, child) {
          final angle = _effects.flipAnimation.value * pi;
          final showFront = angle > pi / 2;
          final shakeOffset = sin(_effects.shakeAnimation.value * 8) * 4;

          return Transform.translate(
            offset: Offset(shakeOffset, 0),
            child: SlideTransition(
              position: _effects.moveAnimation,
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateY(angle),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: showFront
                      ? CardFront(imagePath: widget.card.imagePath)
                      : CardBack(random: _random),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _effects.dispose();
    super.dispose();
  }
}
