import 'dart:math';
import 'package:flutter/material.dart';
/// nút bấm phong cách rừng xanh với hiệu ứng chuyển động và phát sáng
class ForestButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDark;

  const ForestButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    required this.isDark,
  });

  @override
  State<ForestButton> createState() => _ForestButtonState();
}

class _ForestButtonState extends State<ForestButton>
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
