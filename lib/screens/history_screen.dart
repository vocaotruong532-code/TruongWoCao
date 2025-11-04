import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/history_provider.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  String _sortBy = 'score';
  late AnimationController _blinkController;
  late Animation<double> _blinkAnim;

  @override
  void initState() {
    super.initState();
    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _blinkAnim = Tween<double>(begin: 1.0, end: 0.2).animate(_blinkController);
  }

  @override
  void dispose() {
    _blinkController.dispose();
    super.dispose();
  }

  void _triggerBlink() async {
    await _blinkController.forward();
    await _blinkController.reverse();
  }

  Color _resultColor(BuildContext context, String result) {
    switch (result) {
      case 'win':
        return Colors.green;
      case 'lose':
      case 'boom':
        return Colors.red;
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }

  IconData _resultIcon(String result) {
    switch (result) {
      case 'win':
        return Icons.emoji_events_outlined;
      case 'lose':
        return Icons.timer_off_outlined;
      case 'boom':
        return Icons.warning_amber_rounded;
      default:
        return Icons.check_circle_outline;
    }
  }

  String _prettyResult(String r) {
    switch (r) {
      case 'win':
        return 'Thắng';
      case 'lose':
        return 'Thua (hết giờ)';
      case 'boom':
        return 'Thua (nổ bom)';
      default:
        return 'Qua màn';
    }
  }

  String _prettyTime(DateTime t) {
    final dt = t.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(dt.day)}/${two(dt.month)}/${dt.year}, ${two(dt.hour)}:${two(dt.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch sử chơi'),
        actions: [
          IconButton(
            tooltip: 'Xóa lịch sử',
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Xóa lịch sử?'),
                  content: const Text('Bạn có chắc muốn xóa toàn bộ lịch sử?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Hủy'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Xóa'),
                    ),
                  ],
                ),
              );
              if (ok == true && context.mounted) {
                await context.read<HistoryProvider>().clear();
              }
            },
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Builder(
            builder: (context) {
              final isDark = Theme.of(context).brightness == Brightness.dark;
              final bgPath =
                  isDark ? 'backgrounds/dark.gif' : 'backgrounds/light.gif';
              return Image.asset(
                bgPath,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              );
            },
          ),
          Consumer<HistoryProvider>(
            builder: (context, history, _) {
              var data = [...history.entries];
              if (_sortBy == 'score') {
                data.sort((a, b) => b.score.compareTo(a.score));
              } else if (_sortBy == 'level') {
                data.sort((a, b) => b.level.compareTo(a.level));
              } else if (_sortBy == 'player') {
                data.sort((a, b) => a.playerName.compareTo(b.playerName));
              }
              if (data.isEmpty) {
                return const Center(
                  child: Text('Chưa có lịch sử. Hãy chơi một ván!'),
                );
              }
              return Column(
                children: [
                  const SizedBox(height: 8),
                  AnimatedBuilder(
                    animation: _blinkAnim,
                    builder: (context, child) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() => _sortBy = 'score');
                              _triggerBlink();
                            },
                            child: Opacity(
                              opacity: _sortBy == 'score'
                                  ? _blinkAnim.value
                                  : 1.0,
                              child: Text(
                                '🏆 Điểm cao nhất',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: _sortBy == 'score'
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: _sortBy == 'score'
                                      ? Colors.orangeAccent
                                      : null,
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() => _sortBy = 'level');
                              _triggerBlink();
                            },
                            child: Opacity(
                              opacity: _sortBy == 'level'
                                  ? _blinkAnim.value
                                  : 1.0,
                              child: Text(
                                '🎯 Level cao nhất',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: _sortBy == 'level'
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: _sortBy == 'level'
                                      ? Colors.blueAccent
                                      : null,
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() => _sortBy = 'player');
                              _triggerBlink();
                            },
                            child: Opacity(
                              opacity: _sortBy == 'player'
                                  ? _blinkAnim.value
                                  : 1.0,
                              child: Text(
                                '👥 Người chơi',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: _sortBy == 'player'
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: _sortBy == 'player'
                                      ? Colors.purpleAccent
                                      : null,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.all(12),
                      itemCount: data.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final e = data[index];
                        final color = _resultColor(context, e.result);
                        final icon = _resultIcon(e.result);
                        return Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .surface
                                .withOpacity(0.7),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Theme.of(context)
                                  .colorScheme
                                  .outline
                                  .withOpacity(0.4),
                            ),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: color.withOpacity(0.15),
                              child: Icon(icon, color: color),
                            ),
                            title: Text(
                              '${e.playerName} — Level ${e.level} — ${_prettyResult(e.result)}',
                            ),
                            subtitle: Text(
                              'Thời gian: ${_prettyTime(e.time)}\n'
                              'Còn lại: ${e.timeRemaining}s\n'
                              'Điểm: ${e.score}',
                              maxLines: 3,
                            ),
                            trailing: Text(
                              '#${index + 1}',
                              style: TextStyle(
                                color: color,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
