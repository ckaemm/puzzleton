import 'package:shared_preferences/shared_preferences.dart';
import '../models/player_score.dart';

class ScoreService {
  static const String _scoresKey = 'puzzleton_scores';
  static const String _playerNameKey = 'puzzleton_player_name';
  static const int _maxScores = 50;

  /// Skoru kaydet
  static Future<void> saveScore(PlayerScore score) async {
    final prefs = await SharedPreferences.getInstance();
    final scores = await loadScores();
    scores.add(score);

    // En yüksekten en düşüğe sırala
    scores.sort((a, b) => b.score.compareTo(a.score));

    // Maksimum kayıt sayısını aşma
    if (scores.length > _maxScores) {
      scores.removeRange(_maxScores, scores.length);
    }

    await prefs.setString(_scoresKey, PlayerScore.encodeList(scores));
  }

  /// Tüm skorları yükle (yüksekten düşüğe)
  static Future<List<PlayerScore>> loadScores() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_scoresKey);
    if (jsonStr == null || jsonStr.isEmpty) return [];

    try {
      return PlayerScore.decodeList(jsonStr);
    } catch (_) {
      return [];
    }
  }

  /// En yüksek skorları getir (limit ile)
  static Future<List<PlayerScore>> getTopScores({int limit = 20}) async {
    final scores = await loadScores();
    if (scores.length <= limit) return scores;
    return scores.sublist(0, limit);
  }

  /// Oyuncu adını kaydet
  static Future<void> savePlayerName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_playerNameKey, name);
  }

  /// Kayıtlı oyuncu adını getir
  static Future<String?> getPlayerName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_playerNameKey);
  }

  /// Tüm skorları sil
  static Future<void> clearScores() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_scoresKey);
  }
}
