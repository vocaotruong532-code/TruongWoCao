import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/theme_provider.dart';
import '../widgets/forest_button.dart';
import '../widgets/fireflies.dart';
import '../utils/input_decoration.dart';
// đăng nhập người dùng
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
  late final AnimationController _controller;

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
          Image.asset(
            isLight
                ? 'assets/backgrounds/light.gif'
                : 'assets/backgrounds/dark.gif',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const ColoredBox(color: Colors.black),
          ),
          if (!isLight) const Fireflies(count: 30),
          Container(color: Colors.black.withOpacity(0.25)),

          Positioned(
            top: 40,
            right: 20,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              transitionBuilder: (child, anim) =>
                  RotationTransition(turns: anim, child: child),
              child: IconButton(
                key: ValueKey(isLight),
                icon: Icon(
                  isLight
                      ? Icons.dark_mode_rounded
                      : Icons.light_mode_rounded,
                  color:
                      isLight ? Colors.brown[900] : Colors.yellowAccent,
                  size: 30,
                ),
                tooltip: isLight
                    ? 'Chuyển sang Dark mode'
                    : 'Chuyển sang Light mode',
                onPressed: themeProvider.toggleTheme,
              ),
            ),
          ),

          // Nội dung đăng nhập
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
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
                            '🌲 Đăng Nhập',
                            style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      decoration: buildInputDecoration('Tên đăng nhập'),
                      style: const TextStyle(color: Colors.white),
                      onChanged: (val) => _username = val.trim(),
                      validator: (val) =>
                          val == null || val.isEmpty ? 'Nhập tên đăng nhập' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: buildInputDecoration('Mật khẩu'),
                      style: const TextStyle(color: Colors.white),
                      obscureText: true,
                      onChanged: (val) => _password = val.trim(),
                      validator: (val) =>
                          val == null || val.isEmpty ? 'Nhập mật khẩu' : null,
                    ),
                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(_error!,
                            style:
                                const TextStyle(color: Colors.redAccent)),
                      ),
                    const SizedBox(height: 24),
                    ForestButton(
                      icon: Icons.login_rounded,
                      label: 'Đăng nhập',
                      isDark: !isLight,
                      onTap: _login,
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => Navigator.of(context)
                          .pushReplacementNamed('/register'),
                      child: Text(
                        'Chưa có tài khoản? Đăng ký ngay',
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
        ],
      ),
    );
  }
}
