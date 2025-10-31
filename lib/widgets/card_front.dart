import 'dart:math';
import 'package:flutter/material.dart';
/// thẻ hiện mặt trước của thẻ bài
class CardFront extends StatelessWidget {//thẻ hiện mặt trước của thẻ bài
  final String imagePath;
  const CardFront({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    final t = DateTime.now().millisecond / 1000.0;

    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.orange.shade200,
                Colors.pink.shade200,
                Colors.blue.shade200,
                Colors.green.shade200,
              ],
              begin: Alignment(-1 + sin(t), -1 + cos(t)),
              end: Alignment(1 - cos(t), 1 - sin(t)),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white.withOpacity(0.7), width: 2),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.yellowAccent.withOpacity(0.6),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),
        ),
        Center(
          child: Image.asset(
            imagePath,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
          ),
        ),
      ],
    );
  }
}
