import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/theme_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  String _username = '';
  String _password = '';
  String? _error;

  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 6))
          ..repeat();

    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUsername = prefs.getString('username');
    final savedPassword = prefs.getString('password');

    if (savedUsername != null && savedPassword != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.of(context).pushReplacementNamed('/menu');
      });
    }
  }

  Future<void> _login() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final prefs = await SharedPreferences.getInstance();
    final users = prefs.getStringList('users') ?? [];

    final exists = users.any((user) {
      final parts = user.split(':');
      return parts.length >= 2 &&
          parts[0] == _username &&
          parts[1] == _password;
    });

    if (exists) {
      await prefs.setString('username', _username);
      await prefs.setString('password', _password);
      if (mounted) Navigator.of(context).pushReplacementNamed('/menu');
    } else {
      setState(() => _error = 'Sai tên đăng nhập hoặc mật khẩu!');
    }
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w500,
        shadows: [
          Shadow(blurRadius: 6, color: Colors.black54, offset: Offset(1, 1)),
        ],
      ),
      filled: true,
      fillColor: Colors.white.withOpacity(0.15),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.greenAccent.withOpacity(0.6)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.greenAccent, width: 2),
      ),
      hintStyle: const TextStyle(color: Colors.white70, fontSize: 14),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isLight = themeProvider.themeMode == ThemeMode.light;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 🌲 Nền GIF sáng/tối
          Image.asset(
            isLight
                ? 'assets/backgrounds/light.gif'
                : 'assets/backgrounds/dark.gif',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const ColoredBox(color: Colors.black),
          ),
          // 🌌 Đom đóm khi dark mode
          if (!isLight) const Fireflies(count: 30),
          // Hiệu ứng mờ
          Container(color: Colors.black.withOpacity(0.25)),

          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 🌟 Tiêu đề
                    AnimatedBuilder(
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
                            '🌲 Đăng Nhập',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                    blurRadius: 12,
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
                    const SizedBox(height: 24),

                    // 🧠 Tên đăng nhập
                    TextFormField(
                      decoration: _inputDecoration('Tên đăng nhập'),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600),
                      onChanged: (val) => _username = val.trim(),
                      validator: (val) =>
                          val == null || val.isEmpty ? 'Nhập tên đăng nhập' : null,
                    ),
                    const SizedBox(height: 16),

                    // 🔒 Mật khẩu
                    TextFormField(
                      decoration: _inputDecoration('Mật khẩu'),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600),
                      obscureText: true,
                      onChanged: (val) => _password = val.trim(),
                      validator: (val) =>
                          val == null || val.isEmpty ? 'Nhập mật khẩu' : null,
                    ),
                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(_error!,
                            style: const TextStyle(color: Colors.redAccent)),
                      ),
                    const SizedBox(height: 24),

                    // 🌿 Nút đăng nhập
                    _ForestButton(
                      icon: Icons.login_rounded,
                      label: 'Đăng nhập',
                      isDark: !isLight,
                      onTap: _login,
                    ),
                    const SizedBox(height: 16),

                    // Đăng ký
                    TextButton(
                      onPressed: () => Navigator.of(context)
                          .pushReplacementNamed('/register'),
                      child: Text(
                        'Chưa có tài khoản? Đăng ký ngay',
                        style: TextStyle(
                          color: isLight ? Colors.brown[900] : Colors.greenAccent,
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

/// 🌿 Button hiệu ứng rừng
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
  late AnimationController _controller;
  late Animation<double> _glowAnim;
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 6))
          ..repeat();
    _glowAnim = Tween<double>(begin: 0.4, end: 1.0).animate(
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
    final scale = _isPressed ? 0.95 : _isHovered ? 1.05 : 1.0;
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
                      color: widget.isDark
                          ? Colors.blueAccent.withOpacity(
                              _isHovered ? 0.8 : _glowAnim.value * 0.6)
                          : Colors.greenAccent.withOpacity(
                              _isHovered ? 0.9 : _glowAnim.value),
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
                    Icon(Icons.chevron_right_rounded, color: textColor, size: 20),
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

/// ✨ Đom đóm bay khi dark mode
class Fireflies extends StatefulWidget {
  final int count;
  const Fireflies({this.count = 20, super.key});

  @override
  State<Fireflies> createState() => _FirefliesState();
}

class _FirefliesState extends State<Fireflies> with SingleTickerProviderStateMixin {
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
    speeds = List.generate(widget.count, (_) => 0.2 + random.nextDouble() * 0.8);

    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 60))
      ..addListener(() {
        setState(() {
          for (var i = 0; i < positions.length; i++) {
            double dx = positions[i].dx + speeds[i] * 0.002;
            double dy = positions[i].dy + (sin(_controller.value * 2 * pi + i) * 0.001);
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
      final pos = Offset(positions[i].dx * size.width, positions[i].dy * size.height);
      canvas.drawCircle(pos, sizes[i], paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
