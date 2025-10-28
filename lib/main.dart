import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'themes/app_themes.dart';
import 'providers/theme_provider.dart';
import 'providers/sound_provider.dart';
import 'providers/history_provider.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/menu_screen.dart';

void main() {
  runApp(const MemoryCardFlipApp());
}

class MemoryCardFlipApp extends StatelessWidget {
  const MemoryCardFlipApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => SoundProvider()), // 🎵 giữ âm thanh toàn cục
        ChangeNotifierProvider(create: (_) => HistoryProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, theme, _) => MaterialApp(
          title: 'Bậc Thầy Trí Nhớ',
          theme: AppThemes.lightTheme,
          darkTheme: AppThemes.darkTheme,
          themeMode: theme.themeMode,
          debugShowCheckedModeBanner: false,

          builder: (ctx, child) {
            final scale = Provider.of<ThemeProvider>(ctx).textScale;
            final mq = MediaQuery.of(ctx);
            final isLight = theme.themeMode == ThemeMode.light;

            return Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(
                    isLight
                        ? 'assets/backgrounds/light.gif'
                        : 'assets/backgrounds/dark.gif',
                    fit: BoxFit.cover,
                  ),
                ),
                MediaQuery(
                  data: mq.copyWith(textScaler: TextScaler.linear(scale)),
                  child: child ?? const SizedBox.shrink(),
                ),
              ],
            );
          },

          initialRoute: '/login',
          routes: {
            '/login': (context) => const LoginScreen(),
            '/register': (context) => const RegisterScreen(),
            '/menu': (context) => const MenuScreen(),
          },
        ),
      ),
    );
  }
}
