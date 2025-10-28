import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';
import 'card_model.dart';

class GameLevel extends ChangeNotifier {
  final int level;
  final int slevel = 10; // Tổng cộng 10 level
  late final List<CardModel> cards;
  late final int timeLimit;

  Timer? _timer;
  Timer? _previewTimer;
  int _timeRemaining = 0;
  bool _isGameStarted = false;
  bool _isPreview = true;
  bool _inputLocked = true;
  bool _isShuffling = false;

  CardModel? _first;
  CardModel? _second;
  int _matchesFound = 0;

  // ✅ Tổng điểm (lưu và cộng dồn giữa các level)
  int _score = 0;

  final _audio = AudioPlayer();
  bool get isShuffling => _isShuffling;

  VoidCallback? _onMatch;
  VoidCallback? _onMismatch;
  VoidCallback? _onGameOver;
  VoidCallback? _onTimeUp;

  // 👉 callback: khi xáo trộn (để GameScreen biết mà trigger animation)
  VoidCallback? onShuffle;

  // ===================== TRỢ GIÚP =====================
  int _helpUsed = 0;
  static const int _helpLimit = 3;
  static bool _nextLevelPenalty = false;
  // ====================================================

  GameLevel({required this.level}) {
    int baseTime = 30 + (level - 1) * 8;
    if (_nextLevelPenalty) {
      baseTime = max(10, baseTime - 15);
      _nextLevelPenalty = false;
    }
    timeLimit = baseTime;
    _timeRemaining = timeLimit;
    cards = _generateCards();
  }

  int get _pairs => 2 + (level - 1);

  List<CardModel> _generateCards() {
    final images = _getCardImages();
    final list = <CardModel>[];

    for (var i = 0; i < _pairs; i++) {
      final img = images[i % images.length];
      list.add(CardModel(id: i, imagePath: img));
      list.add(CardModel(id: i, imagePath: img));
    }

    // Thêm bomb từ level 4 trở lên
    if (level >= 4) {
      int bombCount = 1 + ((level - 4) ~/ 2);
      for (int i = 0; i < bombCount; i++) {
        list.add(CardModel.boom());
      }
    }

    list.shuffle(Random());
    return list;
  }

  List<String> _getCardImages() => const [
        'assets/cards/1.png',
        'assets/cards/2.png',
        'assets/cards/3.png',
        'assets/cards/4.png',
        'assets/cards/5.png',
        'assets/cards/7.png',
        'assets/cards/8.png',
        'assets/cards/9.png',
        'assets/cards/10.png',
        'assets/cards/11.png',
      ];

  // ===================== KHỞI ĐỘNG LEVEL =====================
  Future<void> startLevel(
    VoidCallback onTimeUp, {
    VoidCallback? onMatch,
    VoidCallback? onMismatch,
    VoidCallback? onGameOver,
  }) async {
    _helpUsed = 0;
    _onMatch = onMatch;
    _onMismatch = onMismatch;
    _onGameOver = onGameOver;
    _onTimeUp = onTimeUp;

    _isGameStarted = true;
    _isPreview = true;
    _inputLocked = true;

    // ✅ Lấy điểm tổng đã lưu (nếu có)
    _score = await _loadTotalScore();

    _matchesFound = 0;

    for (final c in cards) {
      c.isFlipped = true;
      c.isMatched = false;
    }
    notifyListeners();

    // Hiển thị preview 5 giây
    _previewTimer?.cancel();
    _previewTimer = Timer(const Duration(seconds: 5), () {
      for (final c in cards) {
        c.isFlipped = false;
      }

      // 🔥 Xáo trộn thẻ sau preview
      shuffleCards();

      _isPreview = false;
      _inputLocked = false;
      _startTimer(onTimeUp);
      notifyListeners();
    });
  }

  void _startTimer(VoidCallback onTimeUp) {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (_timeRemaining > 0) {
        _timeRemaining--;
        if (isLevelComplete()) {
          await _saveBestLevel();
          await _saveTotalScore(); // ✅ Lưu tổng điểm khi hoàn thành
          timer.cancel();
        }
      } else {
        timer.cancel();
        onTimeUp();
      }
      notifyListeners();
    });
  }

  // ===================== 🔁 XÁO TRỘN SAU PREVIEW =====================
  void shuffleCards() {
    if (!_isGameStarted) return;

    _isShuffling = true;
    _inputLocked = true;

    final matchMap = {for (var c in cards) c.id: c.isMatched};
    final flipMap = {for (var c in cards) c.id: c.isFlipped};
    final oldOrder = List<CardModel>.from(cards);
    final random = Random();
    int tries = 0;

    do {
      cards.shuffle(random);
      tries++;
    } while (
        tries < 10 &&
        List.generate(cards.length, (i) => cards[i] == oldOrder[i])
            .any((same) => same));

    for (var c in cards) {
      c.isMatched = matchMap[c.id] ?? false;
      c.isFlipped = flipMap[c.id] ?? false;
    }

    _playShuffleSound();
    onShuffle?.call();

    notifyListeners();

    Future.delayed(const Duration(milliseconds: 400), () {
      _isShuffling = false;
      _inputLocked = false;
      notifyListeners();
    });
  }

  Future<void> _playShuffleSound() async {
    try {
      await _audio.play(AssetSource('audio/xoat.mp3'));
    } catch (e) {
      debugPrint("Không phát được âm thanh xoạt: $e");
    }
  }

  // ===================== XỬ LÝ GAME =====================
  void onCardTapped(CardModel card) {
    if (!_isGameStarted || _inputLocked || card.isFlipped || card.isMatched) return;

    card.flip();
    notifyListeners();

    // 💥 Nếu là bomb → kết thúc luôn
    if (card.isBoom) {
      _inputLocked = true;
      Future.delayed(const Duration(milliseconds: 600), () {
        _onGameOver?.call();
        card.flip();
        _inputLocked = false;
        notifyListeners();
      });
      return;
    }

    if (_first == null) {
      _first = card;
      return;
    }

    _second = card;
    _inputLocked = true;

    if (_first!.id == _second!.id) {
      Future.delayed(const Duration(milliseconds: 350), () async {
        _first?.match();
        _second?.match();
        _matchesFound++;
        _score += 10; // ✅ cộng điểm
        _onMatch?.call();
        _resetSelection();
        _inputLocked = false;
        await _saveTotalScore(); // ✅ lưu lại điểm cộng dồn
        notifyListeners();
      });
    } else {
      _onMismatch?.call();

      // 🔻 Trừ 3 điểm khi sai (điểm không âm)
      _score = max(0, _score - 3);

      Future.delayed(const Duration(milliseconds: 700), () async {
        _first?.flip();
        _second?.flip();
        _resetSelection();
        _inputLocked = false;
        await _saveTotalScore(); // ✅ lưu lại điểm mới
        notifyListeners();
      });
    }
  }

  void _resetSelection() {
    _first = null;
    _second = null;
  }

  bool isLevelComplete() => _matchesFound == _pairs;

  // ===================== LƯU & TẢI ĐIỂM =====================
  Future<void> _saveTotalScore() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('totalScore', _score);
  }

  Future<int> _loadTotalScore() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('totalScore') ?? 0;
  }

  Future<void> resetTotalScore() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('totalScore', 0);
    _score = 0;
    notifyListeners();
  }

  Future<void> _saveBestLevel() async {
    final prefs = await SharedPreferences.getInstance();
    final best = prefs.getInt('bestLevel') ?? 1;
    if (level > best) await prefs.setInt('bestLevel', level);
  }

  // ===================== TRỢ GIÚP =====================
  bool get canUseHelp => _helpUsed < _helpLimit;
  int get helpUsed => _helpUsed;
  int get helpLimit => _helpLimit;

  void helpAddTime() {
    if (!canUseHelp) return;
    _helpUsed++;
    _timeRemaining += 10;
    _nextLevelPenalty = true;
    notifyListeners();
  }

  void helpRevealAll() {
    if (!canUseHelp) return;
    _helpUsed++;
    for (final c in cards) c.isFlipped = true;
    notifyListeners();

    Future.delayed(const Duration(seconds: 3), () {
      for (final c in cards) {
        if (!c.isMatched) c.isFlipped = false;
      }
      reduceTime(5);
      notifyListeners();
    });
  }

  void helpRemoveBomb() {
    if (!canUseHelp || level < 4) return;
    _helpUsed++;
    final bombIndex = cards.indexWhere((c) => c.isBoom);
    if (bombIndex != -1) {
      cards.removeAt(bombIndex);
      notifyListeners();
    }
  }

  void reduceTime(int seconds) {
    _timeRemaining = (_timeRemaining - seconds).clamp(0, timeLimit).toInt();
    notifyListeners();
  }

  // ===================== GETTERS =====================
  int get timeRemaining => _timeRemaining;
  bool get isGameStarted => _isGameStarted;
  bool get isPreview => _isPreview;
  bool get inputLocked => _inputLocked;
  int get score => _score;
  int get maxTime => timeLimit;

  @override
  void dispose() {
    _timer?.cancel();
    _previewTimer?.cancel();
    _audio.dispose();
    super.dispose();
  }
}
