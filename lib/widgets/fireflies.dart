import 'dart:math';
import 'package:flutter/material.dart';

class Fireflies extends StatefulWidget {
  final int count;
  const Fireflies({this.count = 20, super.key});

  @override
  State<Fireflies> createState() => _FirefliesState();
}

class _FirefliesState extends State<Fireflies>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<Offset> positions;
  late final List<double> sizes;
  late final List<double> speeds;

  @override
  void initState() {
    super.initState();
    final random = Random();
    positions = List.generate(
        widget.count, (_) => Offset(random.nextDouble(), random.nextDouble()));
    sizes = List.generate(widget.count, (_) => 2 + random.nextDouble() * 3);
    speeds =
        List.generate(widget.count, (_) => 0.2 + random.nextDouble() * 0.8);

    _controller = AnimationController(
        vsync: this, duration: const Duration(seconds: 60))
      ..addListener(() {
        setState(() {
          for (var i = 0; i < positions.length; i++) {
            double dx = positions[i].dx + speeds[i] * 0.002;
            double dy = positions[i].dy +
                (sin(_controller.value * 2 * pi + i) * 0.001);
            if (dx > 1.0) dx -= 1.0;
            if (dy > 1.0) dy -= 1.0;
            positions[i] = Offset(dx, dy);
          }
        });
      })
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return CustomPaint(
      size: size,
      painter: _FireflyPainter(positions, sizes),
    );
  }
}

class _FireflyPainter extends CustomPainter {
  final List<Offset> positions;
  final List<double> sizes;
  _FireflyPainter(this.positions, this.sizes);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.yellowAccent.withOpacity(0.8);
    for (var i = 0; i < positions.length; i++) {
      final pos =
          Offset(positions[i].dx * size.width, positions[i].dy * size.height);
      canvas.drawCircle(pos, sizes[i], paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
