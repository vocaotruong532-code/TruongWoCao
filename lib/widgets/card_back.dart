import 'dart:math';
import 'package:flutter/material.dart';
// mặt sau cảu thẻ bài
class CardBack extends StatelessWidget {
  final Random random;
  const CardBack({super.key, required this.random});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.purple.shade200,
                Colors.blue.shade300,
                Colors.pink.shade200,
                Colors.cyan.shade200,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        ...List.generate(8, (i) {
          final dx = random.nextDouble() * 200;
          final dy = random.nextDouble() * 200;
          return Positioned(
            left: dx,
            top: dy,
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.8),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          );
        }),
        Image.asset(
          'assets/cards/back.png',
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
        ),
      ],
    );
  }
}
