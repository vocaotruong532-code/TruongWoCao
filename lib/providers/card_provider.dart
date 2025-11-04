import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/card_model.dart';

class CardProvider with ChangeNotifier {
  String _playerName = '';
  int _score = 0;
  int _timeLeft = 30;
  Timer? _timer;

  List<CardModel> _cards = [];
  List<CardModel> _flipped = [];

  bool _gameOver = false;
  bool _isWin = false;

  String get playerName => _playerName;
  int get score => _score;
  int get timeLeft => _timeLeft;
  List<CardModel> get cards => _cards;
  bool get gameOver => _gameOver;
  bool get isWin => _isWin;

  void setPlayerName(String name) {
    _playerName = name;
    notifyListeners();
  }

  void startGame({int level = 1}) {
    stopTimer();

    _score = 0;
    _timeLeft = 30;
    _gameOver = false;
    _isWin = false;
    _flipped.clear();

    List<CardModel> normalCards = List.generate(5, (i) {
      int id = i + 1;
      return CardModel(id: id, imagePath: 'assets/cards/$id.png');
    });

    _cards = [
      for (var c in normalCards) ...[
        CardModel(id: c.id, imagePath: c.imagePath),
        CardModel(id: c.id, imagePath: c.imagePath),
      ],
    ];

    int bombCount = 0;
    if (level >= 4) {
      bombCount = ((level - 2) ~/ 2).clamp(1, 5);
    }

    for (int i = 0; i < bombCount; i++) {
      _cards.add(CardModel.boom());
    }

    _cards.shuffle(Random());
    _startTimer();
    notifyListeners();
  }

  void flipCard(CardModel card, {int level = 1}) {
    if (_gameOver || card.isFlipped || card.isMatched) return;

    card.flip();
    notifyListeners();

    if (card.isBoom && level >= 4) {
      _timeLeft = (_timeLeft - 5).clamp(0, 999);
      if (_timeLeft <= 0) {
        _endGame(false);
        return;
      }

      notifyListeners();
      Future.delayed(const Duration(milliseconds: 800), () {
        card.flip();
        notifyListeners();
      });
      return;
    }

    _flipped.add(card);
    if (_flipped.length == 2) {
      _checkMatch();
    }
  }

  void _checkMatch() async {
    final first = _flipped[0];
    final second = _flipped[1];

    if (first.id == second.id) {
      first.match();
      second.match();
      _score += 10;
    } else {
      await Future.delayed(const Duration(milliseconds: 800));
      first.flip();
      second.flip();
    }

    _flipped.clear();
    notifyListeners();

    bool allDone = _cards.where((c) => !c.isBoom).every((c) => c.isMatched == true);
    if (allDone) {
      _endGame(true);
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft <= 0) {
        _endGame(false);
      } else {
        _timeLeft--;
        notifyListeners();
      }
    });
  }

  void stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void _endGame(bool win) {
    _gameOver = true;
    _isWin = win;
    stopTimer();
    notifyListeners();
  }
}
