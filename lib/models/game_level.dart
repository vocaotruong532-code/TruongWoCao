// ====================== CÁC THƯ VIỆN ======================
import 'dart:async'; // Dùng để tạo bộ đếm thời gian (Timer)
import 'dart:math';  // Dùng cho random, tạo vị trí thẻ ngẫu nhiên
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Lưu dữ liệu (điểm, cấp độ)
import 'package:audioplayers/audioplayers.dart'; // Phát âm thanh
import 'card_model.dart'; // File định nghĩa cấu trúc của từng thẻ

// ====================== LỚP CHÍNH GAMELEVEL ======================
class GameLevel extends ChangeNotifier {
  // ----- Cấu hình cơ bản -----
  final int level;         // Cấp độ hiện tại
  final int slevel = 10;   // Tổng số level
  late final List<CardModel> cards;  // Danh sách tất cả thẻ
  late final int timeLimit;           // Giới hạn thời gian cho level

  // ----- Các bộ đếm và trạng thái -----
  Timer? _timer;           // Đếm thời gian còn lại khi chơi
  Timer? _previewTimer;    // Bộ đếm thời gian hiển thị preview (xem trước)
  int _timeRemaining = 0;  // Thời gian còn lại
  bool _isGameStarted = false; // Game đã bắt đầu chưa
  bool _isPreview = true;      // Đang trong giai đoạn xem trước
  bool _inputLocked = true;    // Có đang khóa người chơi không (không cho click)
  bool _isShuffling = false;   // Đang xáo trộn thẻ không

  // ----- Dữ liệu tạm khi lật thẻ -----
  CardModel? _first;       // Thẻ đầu tiên được chọn
  CardModel? _second;      // Thẻ thứ hai được chọn
  int _matchesFound = 0;   // Số cặp đã ghép đúng

  // ✅ Tổng điểm được lưu giữa các level
  int _score = 0;

  // ----- Âm thanh -----
  final _audio = AudioPlayer();
  bool get isShuffling => _isShuffling;

  // ----- Callback (hàm gọi khi có sự kiện) -----
  VoidCallback? _onMatch;     // Khi ghép đúng
  VoidCallback? _onMismatch;  // Khi ghép sai
  VoidCallback? _onGameOver;  // Khi thua (hết thời gian hoặc trúng bomb)
  VoidCallback? _onTimeUp;    // Khi hết giờ

  // 👉 Callback để giao diện biết khi nào xáo trộn (cho hiệu ứng)
  VoidCallback? onShuffle;

  // ====================== TRỢ GIÚP ======================
  int _helpUsed = 0;                // Đếm số lần đã dùng trợ giúp
  static const int _helpLimit = 3;  // Giới hạn 3 lần/trận
  static bool _nextLevelPenalty = false; // Giảm thời gian ở level sau nếu dùng trợ giúp
  // =====================================================

  // ------------------- HÀM KHỞI TẠO -------------------
  GameLevel({required this.level}) {
    int baseTime = 30 + (level - 1) * 8; // Mỗi level tăng thêm 8 giây

    if (_nextLevelPenalty) {
      baseTime = max(10, baseTime - 15); // Nếu dùng trợ giúp trước đó → giảm thời gian
      _nextLevelPenalty = false;
    }

    timeLimit = baseTime;
    _timeRemaining = timeLimit;
    cards = _generateCards(); // Gọi hàm tạo bộ bài
  }

  // ------------------- TÍNH SỐ CẶP THẺ -------------------
  int get _pairs => 2 + (level - 1); // Level càng cao → càng nhiều cặp

  // ------------------- HÀM TẠO DANH SÁCH THẺ -------------------
  List<CardModel> _generateCards() {
    final images = _getCardImages();
    final list = <CardModel>[];

    // Tạo cặp thẻ
    for (var i = 0; i < _pairs; i++) {
      final img = images[i % images.length];
      list.add(CardModel(id: i, imagePath: img)); // Thẻ 1
      list.add(CardModel(id: i, imagePath: img)); // Thẻ 2 (cùng id)
    }

    // Từ level 4 trở lên → thêm bomb
    if (level >= 4) {
      int bombCount = 1 + ((level - 4) ~/ 2); // Mỗi 2 level tăng 1 bomb
      for (int i = 0; i < bombCount; i++) {
        list.add(CardModel.boom()); // Thêm thẻ bomb đặc biệt
      }
    }

    list.shuffle(Random()); // Xáo ngẫu nhiên
    return list;
  }

  // ------------------- ẢNH CỦA CÁC THẺ -------------------
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

  // ============================================================
  // ================== KHỞI ĐỘNG MỘT LEVEL =====================
  // ============================================================
  Future<void> startLevel(
    VoidCallback onTimeUp, { // Gọi khi hết thời gian
    VoidCallback? onMatch,
    VoidCallback? onMismatch,
    VoidCallback? onGameOver,
  }) async {
    _helpUsed = 0; // Reset trợ giúp
    _onMatch = onMatch;
    _onMismatch = onMismatch;
    _onGameOver = onGameOver;
    _onTimeUp = onTimeUp;

    _isGameStarted = true;
    _isPreview = true;
    _inputLocked = true;

    // ✅ Lấy điểm tổng đã lưu trước đó
    _score = await _loadTotalScore();
    _matchesFound = 0;

    // Lật tất cả thẻ cho người chơi xem (preview)
    for (final c in cards) {
      c.isFlipped = true;
      c.isMatched = false;
    }
    notifyListeners();

    // Sau 5 giây → úp lại & bắt đầu đếm giờ
    _previewTimer?.cancel();
    _previewTimer = Timer(const Duration(seconds: 5), () {
      for (final c in cards) {
        c.isFlipped = false;
      }

      shuffleCards(); // 🔥 Xáo trộn vị trí thẻ sau preview
      _isPreview = false;
      _inputLocked = false;
      _startTimer(onTimeUp);
      notifyListeners();
    });
  }

  // ============================================================
  // ================== HÀM ĐẾM GIỜ LEVEL =======================
  // ============================================================
  void _startTimer(VoidCallback onTimeUp) {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (_timeRemaining > 0) {
        _timeRemaining--;
        if (isLevelComplete()) {
          await _saveBestLevel();
          await _saveTotalScore(); // Lưu điểm khi thắng
          timer.cancel();
        }
      } else {
        timer.cancel();
        onTimeUp(); // Hết giờ → thua
      }
      notifyListeners();
    });
  }

  // ============================================================
  // =============== 🔁 XÁO TRỘN SAU PREVIEW ===================
  // ============================================================
  void shuffleCards() {
    if (!_isGameStarted) return;

    _isShuffling = true;
    _inputLocked = true;

    // Lưu trạng thái trước khi xáo
    final matchMap = {for (var c in cards) c.id: c.isMatched};
    final flipMap = {for (var c in cards) c.id: c.isFlipped};
    final oldOrder = List<CardModel>.from(cards);
    final random = Random();
    int tries = 0;

    // Xáo nhiều lần để tránh giống vị trí cũ
    do {
      cards.shuffle(random);
      tries++;
    } while (
        tries < 10 &&
        List.generate(cards.length, (i) => cards[i] == oldOrder[i])
            .any((same) => same));

    // Phục hồi trạng thái flip và matched
    for (var c in cards) {
      c.isMatched = matchMap[c.id] ?? false;
      c.isFlipped = flipMap[c.id] ?? false;
    }

    _playShuffleSound();
    onShuffle?.call();
    notifyListeners();

    // Mở lại thao tác sau 400ms
    Future.delayed(const Duration(milliseconds: 400), () {
      _isShuffling = false;
      _inputLocked = false;
      notifyListeners();
    });
  }

  // Âm thanh khi xáo trộn
  Future<void> _playShuffleSound() async {
    try {
      await _audio.play(AssetSource('audio/xoat.mp3'));
    } catch (e) {
      debugPrint("Không phát được âm thanh xoạt: $e");
    }
  }

  // ============================================================
  // ================ XỬ LÝ NGƯỜI CHƠI LẬT THẺ =================
  // ============================================================
  void onCardTapped(CardModel card) {
    if (!_isGameStarted || _inputLocked || card.isFlipped || card.isMatched) return;

    card.flip();
    notifyListeners();

    // 💥 Nếu là bomb → thua luôn
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

    // Nếu là thẻ đầu tiên
    if (_first == null) {
      _first = card;
      return;
    }

    // Nếu là thẻ thứ hai
    _second = card;
    _inputLocked = true;

    // Nếu trùng ID → ghép đúng
    if (_first!.id == _second!.id) {
      Future.delayed(const Duration(milliseconds: 350), () async {
        _first?.match();
        _second?.match();
        _matchesFound++;
        _score += 10;
        _onMatch?.call();
        _resetSelection();
        _inputLocked = false;
        await _saveTotalScore();
        notifyListeners();
      });
    } else {
      _onMismatch?.call();
      _score = max(0, _score - 3); // Trừ 3 điểm khi sai

      Future.delayed(const Duration(milliseconds: 700), () async {
        _first?.flip();
        _second?.flip();
        _resetSelection();
        _inputLocked = false;
        await _saveTotalScore();
        notifyListeners();
      });
    }
  }

  void _resetSelection() {
    _first = null;
    _second = null;
  }

  bool isLevelComplete() => _matchesFound == _pairs;

  // ============================================================
  // ================== LƯU / TẢI DỮ LIỆU ======================
  // ============================================================
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

  // ============================================================
  // ====================== TRỢ GIÚP ============================
  // ============================================================
  bool get canUseHelp => _helpUsed < _helpLimit;
  int get helpUsed => _helpUsed;
  int get helpLimit => _helpLimit;

  // Thêm 10 giây
  void helpAddTime() {
    if (!canUseHelp) return;
    _helpUsed++;
    _timeRemaining += 10;
    _nextLevelPenalty = true;
    notifyListeners();
  }

  // Lật tất cả thẻ trong 3 giây
  void helpRevealAll() {
    if (!canUseHelp) return;
    _helpUsed++;
    for (final c in cards) c.isFlipped = true;
    notifyListeners();

    Future.delayed(const Duration(seconds: 3), () {
      for (final c in cards) {
        if (!c.isMatched) c.isFlipped = false;
      }
      reduceTime(5); // Giảm 5s phạt
      notifyListeners();
    });
  }

  // Xóa 1 bomb
  void helpRemoveBomb() {
    if (!canUseHelp || level < 4) return;
    _helpUsed++;
    final bombIndex = cards.indexWhere((c) => c.isBoom);
    if (bombIndex != -1) {
      cards.removeAt(bombIndex);
      notifyListeners();
    }
  }

  // Giảm thời gian
  void reduceTime(int seconds) {
    _timeRemaining = (_timeRemaining - seconds).clamp(0, timeLimit).toInt();
    notifyListeners();
  }

  // ============================================================
  // ==================== CÁC GETTER ============================
  // ============================================================
  int get timeRemaining => _timeRemaining;
  bool get isGameStarted => _isGameStarted;
  bool get isPreview => _isPreview;
  bool get inputLocked => _inputLocked;
  int get score => _score;
  int get maxTime => timeLimit;

  // ============================================================
  // ===================== HỦY BỘ ĐẾM ==========================
  // ============================================================
  @override
  void dispose() {
    _timer?.cancel();
    _previewTimer?.cancel();
    _audio.dispose();
    super.dispose();
  }
}
