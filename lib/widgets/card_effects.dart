import 'package:flutter/material.dart';

/// Quản lý toàn bộ animation của thẻ (flip / shake / move)
class CardEffects {
  late final AnimationController flipController;
  late final AnimationController shakeController;
  late final AnimationController moveController;

  late final Animation<double> flipAnimation;
  late final Animation<double> shakeAnimation;
  late final Animation<Offset> moveAnimation;

  final TickerProvider vsync;

  CardEffects(this.vsync) {
    // 🌀 Lật thẻ
    flipController = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 300),
    );
    flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: flipController, curve: Curves.linear),
    );

    // 💥 Rung khi nhấn
    shakeController = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 250),
    );
    shakeAnimation = Tween<double>(begin: 0, end: 6).animate(
      CurvedAnimation(parent: shakeController, curve: Curves.elasticIn),
    );

    // 🚀 Di chuyển (bay lên xuống)
    moveController = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 600),
    );
    moveAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -0.2),
    ).animate(
      CurvedAnimation(parent: moveController, curve: Curves.easeInOut),
    );
  }

  /// Khi xáo trộn thẻ
  void playShuffleEffect() {
    moveController
      ..reset()
      ..forward().then((_) => moveController.reverse());
  }

  /// Khi người chơi chọn sai
  void playShake() {
    shakeController
      ..reset()
      ..forward();
  }

  /// Đồng bộ trạng thái lật thẻ
  void syncFlip(bool isFlipped) {
    if (isFlipped && flipController.value == 0) {
      flipController.forward();
    } else if (!isFlipped && flipController.value == 1) {
      flipController.reverse();
    }
  }

  /// Hủy bỏ tất cả animation
  void dispose() {
    flipController.dispose();
    shakeController.dispose();
    moveController.dispose();
  }
}
