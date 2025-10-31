import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/sound_provider.dart';
import 'settings_screen.dart';
import 'history_screen.dart';
import 'name_input_screen.dart';
// màn hình chính với nền động và các nút menu
class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final sound = Provider.of<SoundProvider>(context, listen: false);
      if (sound.isSoundOn) sound.playBGM();
    });
  }

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('username');
    await prefs.remove('password');

    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
  }

  @override
  void dispose() {
    _controller.dispose();
    Provider.of<SoundProvider>(context, listen: false).stopBGM();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sound = Provider.of<SoundProvider>(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final angle = _controller.value * 2 * pi;
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
                '🌲 Bậc Thầy Trí Nhớ',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                        blurRadius: 16,
                        color: Colors.black54,
                        offset: Offset(2, 2)),
                    Shadow(
                        blurRadius: 20,
                        color: Colors.white70,
                        offset: Offset(-2, -2)),
                  ],
                ),
              ),
            );
          },
        ),
        actions: [
          IconButton(
            icon:
                Icon(sound.isSoundOn ? Icons.volume_up : Icons.volume_off_outlined),
            onPressed: () async {
              await sound.toggleSound();
              setState(() {});
            },
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          _buildBackground(isDark),
          if (isDark) const Fireflies(count: 25),
          Container(color: Colors.black.withOpacity(0.15)),
          _buildMenuButtons(context, isDark),
        ],
      ),
    );
  }

  Widget _buildBackground(bool isDark) {
    return Image.asset(
      isDark ? 'assets/backgrounds/dark.gif' : 'assets/backgrounds/light.gif',
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
    );
  }

  Widget _buildMenuButtons(BuildContext context, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _ForestButton(
              icon: Icons.play_arrow_rounded,
              label: 'Bắt đầu',
              isDark: isDark,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NameInputScreen()),
              ),
            ),
            const SizedBox(height: 16),
            _ForestButton(
              icon: Icons.settings_rounded,
              label: 'Cài đặt',
              isDark: isDark,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              ),
            ),
            const SizedBox(height: 16),
            _ForestButton(
              icon: Icons.history_rounded,
              label: 'Lịch sử',
              isDark: isDark,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HistoryScreen()),
              ),
            ),
            const SizedBox(height: 16),
            _ForestButton(
              icon: Icons.exit_to_app_rounded,
              label: 'Thoát game',
              isDark: isDark,
              onTap: () => _logout(context),
            ),
          ],
        ),
      ),
    );
  }
}

/// 🌿 Nút phong cách rừng – hiệu ứng hover & nhấn
class _ForestButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDark;

  const _ForestButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.isDark,
  });

  @override
  State<_ForestButton> createState() => _ForestButtonState();
}

class _ForestButtonState extends State<_ForestButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _glowAnim;
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 6))
          ..repeat();

    _glowAnim = Tween(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scale = _isPressed
        ? 0.95
        : _isHovered
            ? 1.05
            : 1.0;

    final colors = widget.isDark
        ? const [
            Color(0xFF1B5E20),
            Color(0xFF004D40),
            Color(0xFF283593),
            Color(0xFF2E2E2E),
          ]
        : const [
            Color(0xFF4CAF50),
            Color(0xFF8BC34A),
            Color(0xFFFFEB3B),
            Color(0xFF795548),
          ];

    final textColor = widget.isDark ? Colors.white : Colors.black;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          widget.onTap();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedScale(
          scale: scale,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutBack,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final angle = _controller.value * 2 * pi;
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 6),
                padding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 28),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  gradient: LinearGradient(
                    colors: colors,
                    transform: GradientRotation(angle),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (widget.isDark
                              ? Colors.blueAccent
                              : Colors.greenAccent)
                          .withOpacity(
                        _isHovered ? 0.9 : _glowAnim.value * 0.6,
                      ),
                      blurRadius: _isHovered ? 18 : 12,
                      spreadRadius: _isHovered ? 3 : 2,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(widget.icon, color: textColor, size: 22),
                    const SizedBox(width: 10),
                    Text(
                      widget.label,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                        shadows: [
                          Shadow(
                            blurRadius: 6,
                            color: Colors.black.withOpacity(0.3),
                            offset: const Offset(1, 1),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.chevron_right_rounded,
                        color: textColor, size: 20),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// ✨ Hiệu ứng đom đóm khi dark mode
class Fireflies extends StatefulWidget {
  final int count;
  final Size? area;

  const Fireflies({this.count = 20, this.area, super.key});

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

    positions =
        List.generate(widget.count, (_) => Offset(random.nextDouble(), random.nextDouble()));
    sizes = List.generate(widget.count, (_) => 2 + random.nextDouble() * 3);
    speeds = List.generate(widget.count, (_) => 0.2 + random.nextDouble() * 0.8);

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    )
      ..addListener(_updateFireflies)
      ..repeat();
  }

  void _updateFireflies() {
    setState(() {
      for (var i = 0; i < positions.length; i++) {
        double dx = positions[i].dx + speeds[i] * 0.002;
        double dy = positions[i].dy + sin(_controller.value * 2 * pi + i) * 0.001;
        if (dx > 1.0) dx -= 1.0;
        if (dy > 1.0) dy -= 1.0;
        positions[i] = Offset(dx, dy);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final area = widget.area ?? MediaQuery.of(context).size;
    return CustomPaint(
      size: area,
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
    final paint = Paint()..color = Colors.yellowAccent.withOpacity(0.7);
    for (var i = 0; i < positions.length; i++) {
      final pos = Offset(positions[i].dx * size.width, positions[i].dy * size.height);
      canvas.drawCircle(pos, sizes[i], paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
