import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SoundProvider extends ChangeNotifier {
  late final AudioPlayer _bgmPlayer;
  bool _isSoundOn = true;
  bool get isSoundOn => _isSoundOn;

  SoundProvider() {
    _bgmPlayer = AudioPlayer(playerId: 'bgm_player');
    _init();
  }

 
  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    _isSoundOn = prefs.getBool('sound_on') ?? true;

    await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
    await _bgmPlayer.setVolume(0.5);

    if (_isSoundOn) {
  
      Future.delayed(const Duration(milliseconds: 500), () {
        playBGM();
      });
    }
  }

  
  Future<void> toggleSound() async {
    final prefs = await SharedPreferences.getInstance();
    _isSoundOn = !_isSoundOn;
    await prefs.setBool('sound_on', _isSoundOn);

    if (_isSoundOn) {
      await playBGM();
    } else {
      await stopBGM();
    }

    notifyListeners();
  }


  Future<void> playBGM() async {
    if (!_isSoundOn) return;
    try {
      debugPrint('🎵 Bắt đầu phát nhạc nền...');
      await _bgmPlayer.stop(); 
      await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
      await _bgmPlayer.setVolume(0.5);
      await _bgmPlayer.play(AssetSource('audio/BGM.mp3'), volume: 0.5);
      debugPrint('✅ Nhạc nền đang phát!');
    } catch (e) {
      debugPrint('⚠️ Lỗi phát nhạc nền: $e');
    }
  }

 
  Future<void> stopBGM() async {
    try {
      await _bgmPlayer.stop();
      debugPrint('🛑 Dừng nhạc nền');
    } catch (e) {
      debugPrint('⚠️ Lỗi dừng nhạc nền: $e');
    }
  }


  Future<void> _playEffect(String assetPath, {double volume = 1.0}) async {
    if (!_isSoundOn) return;
    try {
      final effectPlayer = AudioPlayer(
        playerId: 'sfx_${DateTime.now().millisecondsSinceEpoch}',
      );
      await effectPlayer.setPlayerMode(PlayerMode.lowLatency);
      await effectPlayer.play(AssetSource(assetPath), volume: volume);
      effectPlayer.onPlayerComplete.listen((_) => effectPlayer.dispose());
    } catch (e) {
      debugPrint('⚠️ Lỗi phát hiệu ứng $assetPath: $e');
    }
  }


  Future<void> playClick() async => _playEffect('audio/click.mp3', volume: 0.9);
  Future<void> playFlip() async => _playEffect('audio/flip.mp3');
  Future<void> playMatch() async => _playEffect('audio/match.mp3');
  Future<void> playMismatch() async => _playEffect('audio/mismatch.mp3');
  Future<void> playWin() async => _playEffect('audio/win.mp3');
  Future<void> playLose() async => _playEffect('audio/lose.mp3');
  Future<void> playExplosion() async => _playEffect('audio/boom.mp3');

  @override
  void dispose() {
    _bgmPlayer.dispose();
    super.dispose();
  }
}
