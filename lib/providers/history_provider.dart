import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// HistoryProvider
/// ----------------
/// Lưu và đọc lịch sử chơi từ SharedPreferences dưới dạng JSON.
/// Mỗi bản ghi gồm:
/// - playerName: tên người chơi
/// - thời gian
/// - level
/// - kết quả (win/lose/clear)
/// - thời gian còn lại
/// - điểm (score)
class HistoryProvider extends ChangeNotifier {
  static const _prefsKey = 'history_records_v3'; // đổi v3 để tránh lỗi dữ liệu cũ
  final List<HistoryEntry> _entries = [];

  List<HistoryEntry> get entries => List.unmodifiable(_entries);

  HistoryProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        final list = jsonDecode(raw) as List<dynamic>;
        _entries
          ..clear()
          ..addAll(
            list.map((e) => HistoryEntry.fromJson(e as Map<String, dynamic>)),
          );
      } catch (_) {
        // ignore corrupted data
      }
    }
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(_entries.map((e) => e.toJson()).toList());
    await prefs.setString(_prefsKey, raw);
  }

  /// Thêm một bản ghi lịch sử
  /// `score` mặc định = 0, `playerName` mặc định là 'Người chơi'
  Future<void> addEntry({
    required String playerName,
    required DateTime time,
    required int level,
    required String result, // 'win' | 'lose' | 'clear'
    required int timeRemaining,
    int score = 0,
  }) async {
    _entries.insert(
      0,
      HistoryEntry(
        playerName: playerName,
        time: time,
        level: level,
        result: result,
        timeRemaining: timeRemaining,
        score: score,
      ),
    );
    await _save();
    notifyListeners();
  }

  Future<void> clear() async {
    _entries.clear();
    await _save();
    notifyListeners();
  }
}

/// Model một bản ghi lịch sử
class HistoryEntry {
  final String playerName; // ✅ tên người chơi
  final DateTime time;
  final int level;
  final String result; // 'win' | 'lose' | 'clear'
  final int timeRemaining;
  final int score;

  HistoryEntry({
    required this.playerName,
    required this.time,
    required this.level,
    required this.result,
    required this.timeRemaining,
    required this.score,
  });

  Map<String, dynamic> toJson() => {
        'playerName': playerName,
        'time': time.toIso8601String(),
        'level': level,
        'result': result,
        'timeRemaining': timeRemaining,
        'score': score,
      };

  factory HistoryEntry.fromJson(Map<String, dynamic> json) => HistoryEntry(
        playerName: json['playerName'] as String? ?? 'Người chơi',
        time: DateTime.tryParse(json['time'] as String? ?? '') ?? DateTime.now(),
        level: json['level'] as int? ?? 1,
        result: json['result'] as String? ?? 'clear',
        timeRemaining: json['timeRemaining'] as int? ?? 0,
        score: json['score'] as int? ?? 0,
      );
}
