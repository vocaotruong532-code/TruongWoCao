import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/theme_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  String _username = '';
  String _password = '';
  String _confirmPassword = '';
  String? _error;

  late AnimationController _controller;
  late List<Firefly> _fireflies;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 6))
          ..repeat();


    final random = Random();
    _fireflies = List.generate(
      25,
      (_) => Firefly(
        x: random.nextDouble(),
        y: random.nextDouble(),
        dx: random.nextDouble() * 0.002 - 0.001,
        dy: random.nextDouble() * 0.002 - 0.001,
        radius: random.nextDouble() * 2 + 1.5,
        opacity: 0.5 + random.nextDouble() * 0.5,
      ),
    );

    _controller.addListener(() {
      for (var f in _fireflies) {
        f.update();
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final prefs = await SharedPreferences.getInstance();
    final users = prefs.getStringList('users') ?? [];

    final usernameExists = users.any((user) {
      final parts = user.split(':');
      return parts.isNotEmpty && parts[0] == _username;
    });

    if (usernameExists) {
      setState(() => _error = "Tên đăng nhập đã tồn tại!");
      return;
    }

    if (_password != _confirmPassword) {
      setState(() => _error = "Mật khẩu xác nhận không khớp!");
      return;
    }

    users.add("$_username:$_password");
    await prefs.setStringList('users', users);

    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/login', arguments: {
      'username': _username,
      'password': _password,
    });
  }

  InputDecoration _inputDecoration(String label, Color color) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: color),
      filled: true,
      fillColor: Colors.white.withOpacity(0.12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.greenAccent.shade100),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.greenAccent.shade200, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isLight = themeProvider.themeMode == ThemeMode.light;
    final textColor = isLight ? Colors.black : Colors.white;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 🌲 Nền GIF động
          Image.asset(
            isLight
                ? 'assets/backgrounds/light.gif'
                : 'assets/backgrounds/dark.gif',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                const ColoredBox(color: Colors.black),
          ),

         
          if (!isLight) CustomPaint(painter: FireflyPainter(_fireflies)),

          
          Container(color: Colors.black.withOpacity(0.25)),

          
          Positioned(
            top: 40,
            right: 20,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              transitionBuilder: (child, anim) =>
                  RotationTransition(turns: anim, child: child),
              child: IconButton(
                key: ValueKey(isLight),
                icon: Icon(
                  isLight
                      ? Icons.dark_mode_rounded
                      : Icons.light_mode_rounded,
                  color: isLight ? Colors.brown[900] : Colors.yellowAccent,
                  size: 30,
                ),
                tooltip: isLight
                    ? 'Chuyển sang Dark mode'
                    : 'Chuyển sang Light mode',
                onPressed: themeProvider.toggleTheme,
              ),
            ),
          ),

         
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.35),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.greenAccent.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 30),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                     
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
                              '🌿 Đăng Ký Tài Khoản',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    blurRadius: 12,
                                    color: Colors.black54,
                                    offset: Offset(2, 2),
                                  ),
                                  Shadow(
                                    blurRadius: 20,
                                    color: Colors.white70,
                                    offset: Offset(-2, -2),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),

                     
                      TextFormField(
                        style: TextStyle(color: textColor),
                        decoration:
                            _inputDecoration('Tên đăng nhập', textColor),
                        onChanged: (val) => _username = val.trim(),
                        validator: (val) => val == null || val.isEmpty
                            ? 'Nhập tên đăng nhập'
                            : null,
                      ),
                      const SizedBox(height: 16),

                      
                      TextFormField(
                        style: TextStyle(color: textColor),
                        obscureText: true,
                        decoration: _inputDecoration('Mật khẩu', textColor),
                        onChanged: (val) => _password = val.trim(),
                        validator: (val) => val == null || val.isEmpty
                            ? 'Nhập mật khẩu'
                            : null,
                      ),
                      const SizedBox(height: 16),

                      
                      TextFormField(
                        style: TextStyle(color: textColor),
                        obscureText: true,
                        decoration: _inputDecoration(
                            'Xác nhận mật khẩu', textColor),
                        onChanged: (val) => _confirmPassword = val.trim(),
                        validator: (val) => val == null || val.isEmpty
                            ? 'Xác nhận mật khẩu'
                            : null,
                      ),

                      if (_error != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            _error!,
                            style:
                                const TextStyle(color: Colors.redAccent),
                          ),
                        ),
                      const SizedBox(height: 24),

                      
                      _ForestButton(
                        icon: Icons.person_add_alt_1_rounded,
                        label: 'Đăng ký',
                        isDark: !isLight,
                        onTap: _register,
                      ),
                      const SizedBox(height: 16),

                      
                      TextButton(
                        onPressed: () => Navigator.of(context)
                            .pushReplacementNamed('/login'),
                        child: Text(
                          'Đã có tài khoản? Đăng nhập ngay',
                          style: TextStyle(
                            color: isLight
                                ? Colors.brown[900]
                                : Colors.greenAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


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
                margin:
                    const EdgeInsets.symmetric(vertical: 6),
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


class Firefly {
  double x, y, dx, dy, radius, opacity;

  Firefly({
    required this.x,
    required this.y,
    required this.dx,
    required this.dy,
    required this.radius,
    required this.opacity,
  });

  void update() {
    x += dx;
    y += dy;
    if (x < 0 || x > 1) dx *= -1;
    if (y < 0 || y > 1) dy *= -1;
  }
}


class FireflyPainter extends CustomPainter {
  final List<Firefly> fireflies;
  FireflyPainter(this.fireflies);

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    for (final f in fireflies) {
      paint.color =
          Colors.yellowAccent.withOpacity(f.opacity);
      canvas.drawCircle(
          Offset(f.x * size.width, f.y * size.height),
          f.radius,
          paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
