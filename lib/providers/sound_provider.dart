import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
// cung cấp âm thanh cho trò chơi
class SoundProvider extends ChangeNotifier {
  late final AudioPlayer _bgmPlayer; // 🔊 Player riêng cho nhạc nền
  bool _isSoundOn = true;
  bool get isSoundOn => _isSoundOn;

  SoundProvider() {
    _bgmPlayer = AudioPlayer(playerId: 'bgm_player');
    _init();
  }

  /// 🔧 Khởi tạo âm thanh và phát BGM nếu bật
  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    _isSoundOn = prefs.getBool('sound_on') ?? true;

    await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
    await _bgmPlayer.setVolume(0.5);

    if (_isSoundOn) {
      // Đợi một chút sau khi app load để tránh lỗi chưa gắn Source
      Future.delayed(const Duration(milliseconds: 500), () {
        playBGM();
      });
    }
  }

  /// 🔄 Bật/tắt âm thanh
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

  /// 🎶 Phát nhạc nền (loop)
  Future<void> playBGM() async {
    if (!_isSoundOn) return;
    try {
      debugPrint('🎵 Bắt đầu phát nhạc nền...');
      await _bgmPlayer.stop(); // Dừng nếu đang phát cũ
      await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
      await _bgmPlayer.setVolume(0.5);
      await _bgmPlayer.play(AssetSource('audio/BGM.mp3'), volume: 0.5);
      debugPrint('✅ Nhạc nền đang phát!');
    } catch (e) {
      debugPrint('⚠️ Lỗi phát nhạc nền: $e');
    }
  }

  /// ⏹ Dừng nhạc nền
  Future<void> stopBGM() async {
    try {
      await _bgmPlayer.stop();
      debugPrint('🛑 Dừng nhạc nền');
    } catch (e) {
      debugPrint('⚠️ Lỗi dừng nhạc nền: $e');
    }
  }

  /// 🎧 Phát hiệu ứng ngắn (click, match, win, ...)
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

  // 🔊 Các hiệu ứng
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
