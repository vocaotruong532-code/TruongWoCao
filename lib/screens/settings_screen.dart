library;

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/sound_provider.dart';
// cài đặt giao diện và âm thanh
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài đặt'),
        centerTitle: true,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          /// 🌄 Nền động ngày/đêm (GIF)
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              final isDark = themeProvider.themeMode == ThemeMode.dark;
              final path = isDark
                  ? 'assets/backgrounds/dark.gif'
                  : 'assets/backgrounds/light.gif';
              return Image.asset(
                path,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              );
            },
          ),

          /// 🪄 Hiệu ứng đom đóm (chỉ hiện khi dark mode)
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, _) {
              if (themeProvider.themeMode != ThemeMode.dark) {
                return const SizedBox.shrink();
              }
              return AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  final t = _controller.value;
                  final fireflies = List.generate(15, (i) {
                    final dx =
                        (sin(t * 2 * pi * (i + 1) / 3) * 0.4 + 0.5);
                    final dy =
                        (cos(t * 2 * pi * (i + 1) / 4) * 0.4 + 0.5);
                    final size =
                        (sin(t * 2 * pi * (i + 1)) * 3).abs() + 2.5;

                    return Positioned(
                      left: MediaQuery.of(context).size.width * dx,
                      top: MediaQuery.of(context).size.height * dy,
                      child: Container(
                        width: size,
                        height: size,
                        decoration: BoxDecoration(
                          color: Colors.yellowAccent.withOpacity(0.8),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.yellowAccent.withOpacity(0.8),
                              blurRadius: 8,
                              spreadRadius: 3,
                            ),
                          ],
                        ),
                      ),
                    );
                  });
                  return Stack(children: fireflies);
                },
              );
            },
          ),

          /// 🌿 Giao diện cài đặt chính
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Consumer2<ThemeProvider, SoundProvider>(
              builder: (context, themeProvider, soundProvider, child) {
                final isDark = themeProvider.themeMode == ThemeMode.dark;
                final textColor = isDark ? Colors.white : Colors.black;

                return SingleChildScrollView(
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, _) {
                      final angle = _controller.value * 2 * pi;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _SettingSection(
                            title: "Giao diện",
                            icon: Icons.dark_mode_outlined,
                            textColor: textColor,
                            angle: angle,
                            isDark: isDark,
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Chế độ tối',
                                    style: TextStyle(color: textColor),
                                  ),
                                ),
                                Switch.adaptive(
                                  value: isDark,
                                  onChanged: (_) =>
                                      themeProvider.toggleTheme(),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          _SettingSection(
                            title: "Âm thanh",
                            icon: soundProvider.isSoundOn
                                ? Icons.volume_up_rounded
                                : Icons.volume_off_rounded,
                            textColor: textColor,
                            angle: angle,
                            isDark: isDark,
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Bật âm thanh',
                                    style: TextStyle(color: textColor),
                                  ),
                                ),
                                Switch.adaptive(
                                  value: soundProvider.isSoundOn,
                                  activeColor: Colors.green,
                                  onChanged: (_) =>
                                      soundProvider.toggleSound(),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          _SettingSection(
                            title: "Cỡ chữ",
                            icon: Icons.text_fields_rounded,
                            textColor: textColor,
                            angle: angle,
                            isDark: isDark,
                            child: Column(
                              children: [
                                Slider(
                                  value: themeProvider.textScale,
                                  min: 0.8,
                                  max: 1.4,
                                  divisions: 6,
                                  label: themeProvider.textScale
                                      .toStringAsFixed(1),
                                  onChanged: (v) =>
                                      themeProvider.setTextScale(v),
                                ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    'x${themeProvider.textScale.toStringAsFixed(1)}',
                                    style: TextStyle(color: textColor),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// 🌳 Widget hiển thị từng phần cài đặt (phong cách nút menu)
class _SettingSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  final Color textColor;
  final double angle;
  final bool isDark;

  const _SettingSection({
    required this.title,
    required this.icon,
    required this.child,
    required this.textColor,
    required this.angle,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final gradientColors = isDark
        ? const [
            Color(0xFF1B5E20), // xanh rừng đậm
            Color(0xFF004D40), // xanh lam ngọc
            Color(0xFF283593), // tím xanh
            Color(0xFF2E2E2E), // xám đêm
          ]
        : const [
            Color(0xFF4CAF50),
            Color(0xFF8BC34A),
            Color(0xFFFFEB3B),
            Color(0xFF795548),
          ];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          colors: gradientColors,
          transform: GradientRotation(angle),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.blueAccent.withOpacity(0.6)
                : Colors.greenAccent.withOpacity(0.5),
            blurRadius: 10,
            spreadRadius: 3,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: textColor),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.black.withOpacity(0.3)
                  : Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(16),
            ),
            child: child,
          ),
        ],
      ),
    );
  }
}
