import 'dart:math';
import 'package:flutter/material.dart';
import 'game_screen.dart';
// tên người chơi nhập vào trước khi bắt đầu trò chơi
class NameInputScreen extends StatefulWidget {
  const NameInputScreen({super.key});

  @override
  State<NameInputScreen> createState() => _NameInputScreenState();
}

class _NameInputScreenState extends State<NameInputScreen>
    with SingleTickerProviderStateMixin {
  final _controller = TextEditingController();
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  void _confirm() {
    if (_controller.text.trim().isNotEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              GameScreen(playerName: _controller.text.trim()),
        ),
      );
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgPath = isDark ? 'backgrounds/dark.gif' : 'backgrounds/light.gif';

    return Scaffold(
      appBar: AppBar(
        title: AnimatedBuilder(
          animation: _animController,
          builder: (context, _) {
            final angle = _animController.value * 2 * pi;
            return ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: const [
                  Colors.greenAccent,
                  Colors.yellowAccent,
                  Colors.lightGreen,
                  Colors.brown,
                ],
                transform: GradientRotation(angle),
              ).createShader(bounds),
              child: const Text(
                '🌿 Nhập tên người chơi',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  shadows: [
                    Shadow(
                      blurRadius: 12,
                      color: Colors.black45,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        centerTitle: true,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Ảnh nền
          Image.asset(
            bgPath,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
          ),
          if (isDark) const _Fireflies(count: 20),
          Container(color: Colors.black.withOpacity(0.25)),

          // Form nhập tên
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.black.withOpacity(0.5)
                      : Colors.white.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.greenAccent.withOpacity(0.5),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedBuilder(
                      animation: _animController,
                      builder: (context, _) {
                        final angle = _animController.value * 2 * pi;
                        return ShaderMask(
                          shaderCallback: (bounds) => LinearGradient(
                            colors: isDark
                                ? const [
                                    Colors.greenAccent,
                                    Colors.tealAccent,
                                    Colors.lightGreenAccent,
                                  ]
                                : const [
                                    Colors.lightGreen,
                                    Colors.yellowAccent,
                                    Colors.green,
                                  ],
                            transform: GradientRotation(angle),
                          ).createShader(bounds),
                          child: TextField(
                            controller: _controller,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              shadows: [
                                Shadow(
                                  blurRadius: 6,
                                  color: Colors.black,
                                  offset: Offset(1, 1),
                                ),
                              ],
                            ),
                            decoration: InputDecoration(
                              labelText: 'Tên người chơi',
                              labelStyle: TextStyle(
                                color: isDark
                                    ? Colors.greenAccent
                                    : Colors.green.shade900,
                                fontWeight: FontWeight.bold,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: isDark
                                      ? Colors.greenAccent
                                      : Colors.green.shade700,
                                  width: 2,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Colors.yellowAccent,
                                  width: 2.5,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isDark ? Colors.greenAccent : Colors.green,
                        foregroundColor:
                            isDark ? Colors.black : Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 12,
                      ),
                      onPressed: _confirm,
                      icon: const Icon(Icons.check_rounded, size: 24),
                      label: const Text(
                        'Xác nhận',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ✨ Hiệu ứng đom đóm
class _Fireflies extends StatefulWidget {
  final int count;
  const _Fireflies({this.count = 20});

  @override
  State<_Fireflies> createState() => _FirefliesState();
}

class _FirefliesState extends State<_Fireflies>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<Offset> positions;
  late final List<double> sizes;
  late final List<double> speeds;
  final Random random = Random();

  @override
  void initState() {
    super.initState();
    positions = List.generate(
      widget.count,
      (_) => Offset(random.nextDouble(), random.nextDouble()),
    );
    sizes = List.generate(widget.count, (_) => 2 + random.nextDouble() * 3);
    speeds = List.generate(widget.count, (_) => 0.2 + random.nextDouble() * 0.8);

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    )
      ..addListener(() {
        setState(() {
          for (int i = 0; i < positions.length; i++) {
            double dx = positions[i].dx + speeds[i] * 0.002;
            double dy =
                positions[i].dy + sin(_controller.value * 2 * pi + i) * 0.001;
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
    return CustomPaint(size: size, painter: _FireflyPainter(positions, sizes));
  }
}

class _FireflyPainter extends CustomPainter {
  final List<Offset> positions;
  final List<double> sizes;

  _FireflyPainter(this.positions, this.sizes);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.yellowAccent.withOpacity(0.8);
    for (int i = 0; i < positions.length; i++) {
      final pos =
          Offset(positions[i].dx * size.width, positions[i].dy * size.height);
      canvas.drawCircle(pos, sizes[i], paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
