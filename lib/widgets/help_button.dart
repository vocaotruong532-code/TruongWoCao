import 'package:flutter/material.dart';

class AnimatedHelpButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final List<Color> colors;

  const AnimatedHelpButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = onPressed != null;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(seconds: 2),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        final animatedColor =
            Color.lerp(colors[0], colors[1], (0.5 + 0.5 * (value * 2 % 1))) ?? colors[0];
        final effectiveColor = isEnabled ? animatedColor : Colors.grey.withOpacity(0.4);

        return Stack(
          alignment: Alignment.center,
          children: [
            if (isEnabled)
              Container(
                width: 70 + value * 25,
                height: 70 + value * 25,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: effectiveColor.withOpacity(0.15 * (1 - value)),
                ),
              ),
            InkWell(
              onTap: isEnabled ? onPressed : null,
              borderRadius: BorderRadius.circular(30),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  gradient: LinearGradient(
                    colors: isEnabled
                        ? [effectiveColor, colors[1]]
                        : [Colors.grey.shade700, Colors.grey.shade500],
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, color: isEnabled ? Colors.white : Colors.white54),
                    const SizedBox(width: 6),
                    Text(
                      label,
                      style: TextStyle(
                        color: isEnabled ? Colors.white : Colors.white60,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
