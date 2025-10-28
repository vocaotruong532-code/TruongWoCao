import 'package:flutter/material.dart';
import '../screens/menu_screen.dart';
// hộp thoại trò chơi kết thúc

class GameDialogs {
  static void showLose(BuildContext context, {required VoidCallback restart}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Thua cuộc'),
        content: const Text('Bạn đã hết thời gian! Chơi lại?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              restart();
            },
            child: const Text('Chơi lại'),
          ),
        ],
      ),
    );
  }

  static void showBoom(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.red.shade900.withOpacity(0.9),
        title: const Text(
          '💥 BOOM 💥',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Bạn đã lật trúng bom và thua cuộc!',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const MenuScreen()),
                (route) => false,
              );
            },
            child: const Text(
              'Về Menu',
              style: TextStyle(color: Colors.orangeAccent),
            ),
          ),
        ],
      ),
    );
  }

  static void showWin(BuildContext context, {required VoidCallback restart}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Chiến thắng!'),
        content: const Text('Bạn đã hoàn thành tất cả các level.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              restart();
            },
            child: const Text('Chơi lại'),
          ),
        ],
      ),
    );
  }
}
