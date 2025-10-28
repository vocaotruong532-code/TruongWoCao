import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game_level.dart'; // ✅ chỉ cần import file này thôi
import '../widgets/card_widget.dart';
import '../providers/sound_provider.dart';
import '../providers/history_provider.dart';
import 'menu_screen.dart';
import '../widgets/help_button.dart';
import '../widgets/game_board.dart';
import '../widgets/game_background.dart';
import '../widgets/game_over_dialogs.dart';
// trò chơi chính
class GameScreen extends StatefulWidget {
  final String playerName;
  const GameScreen({super.key, required this.playerName});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late GameLevel _gameLevel;

  @override
  void initState() {
    super.initState();
    _gameLevel = GameLevel(level: 1);
    _startLevel();
  }

  void _startLevel() {
    final sound = Provider.of<SoundProvider>(context, listen: false);
    final history = Provider.of<HistoryProvider>(context, listen: false);

    _gameLevel.startLevel(
      () {
        sound.playLose();
        history.addEntry(
          time: DateTime.now(),
          level: _gameLevel.level,
          result: 'lose',
          timeRemaining: _gameLevel.timeRemaining,
          score: _gameLevel.score,
          playerName: widget.playerName,
        );
        GameDialogs.showLose(context, restart: _restartGame);
      },
      onMatch: () {
        sound.playMatch();
        setState(() {});
      },
      onMismatch: () => sound.playMismatch(),
      onGameOver: () {
        sound.playExplosion();
        history.addEntry(
          time: DateTime.now(),
          level: _gameLevel.level,
          result: 'boom',
          timeRemaining: _gameLevel.timeRemaining,
          score: _gameLevel.score,
          playerName: widget.playerName,
        );
        GameDialogs.showBoom(context);
      },
    );
  }

  void _nextLevel() {
    final history = Provider.of<HistoryProvider>(context, listen: false);

    if (_gameLevel.level >= _gameLevel.slevel) {
      GameDialogs.showWin(context, restart: _restartGame);
      return;
    }

    history.addEntry(
      time: DateTime.now(),
      level: _gameLevel.level,
      result: 'clear',
      timeRemaining: _gameLevel.timeRemaining,
      score: _gameLevel.score,
      playerName: widget.playerName,
    );

    setState(() {
      _gameLevel.dispose();
      _gameLevel = GameLevel(level: _gameLevel.level + 1);
    });
    _startLevel();
  }

  void _restartGame() {
    setState(() {
      _gameLevel.dispose();
      _gameLevel = GameLevel(level: 1);
    });
    _startLevel();
  }

  @override
  Widget build(BuildContext context) {
    final sound = Provider.of<SoundProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: AnimatedBuilder(
          animation: _gameLevel,
          builder: (context, _) => Text(
            '${widget.playerName} | Level ${_gameLevel.level} | '
            'Điểm: ${_gameLevel.score} | '
            'Thời gian: ${_gameLevel.timeRemaining}s',
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(sound.isSoundOn ? Icons.volume_up : Icons.volume_off),
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
          const GameBackground(),
          ChangeNotifierProvider.value(
            value: _gameLevel,
            child: Column(
              children: [
                Expanded(
                  child: GameBoard(
                    onLevelComplete: _nextLevel,
                  ),
                ),
                Consumer<GameLevel>(
                  builder: (context, game, _) {
                    return Container(
                      padding: const EdgeInsets.all(8),
                      color: Colors.black.withOpacity(0.3),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              AnimatedHelpButton(
                                icon: Icons.add_alarm,
                                label: "+10s",
                                onPressed: game.canUseHelp
                                    ? () {
                                        game.helpAddTime();
                                        sound.playMatch();
                                      }
                                    : null,
                                colors: [Colors.pinkAccent, Colors.orangeAccent],
                              ),
                              AnimatedHelpButton(
                                icon: Icons.visibility,
                                label: "Xem 3s",
                                onPressed: game.canUseHelp
                                    ? () {
                                        game.helpRevealAll();
                                        sound.playMatch();
                                      }
                                    : null,
                                colors: [Colors.cyanAccent, Colors.blueAccent],
                              ),
                              AnimatedHelpButton(
                                icon: Icons.delete_forever,
                                label: "Xóa bomb",
                                onPressed: (game.canUseHelp && game.level >= 4)
                                    ? () {
                                        game.helpRemoveBomb();
                                        sound.playMatch();
                                      }
                                    : null,
                                colors: [Colors.redAccent, Colors.purpleAccent],
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Trợ giúp đã dùng: ${game.helpUsed}/${game.helpLimit}",
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _gameLevel.dispose();
    super.dispose();
  }
}
