import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/game_config.dart';

class DailyChallengeService {
  DailyChallengeService._();

  static const _playedPrefix = 'daily_played_';
  static const _scorePrefix = 'daily_score_';

  /// Bugünün seed'i: yıl*10000 + ay*100 + gün
  static int get todaySeed {
    final now = DateTime.now();
    return now.year * 10000 + now.month * 100 + now.day;
  }

  /// Bugünün key'i (SharedPreferences'ta arama için)
  static String get _todayKey => todaySeed.toString();

  /// Bugünün deterministik Random nesnesi
  static Random get todayRandom => Random(todaySeed);

  /// Günlük challenge için sabit Orta zorluk
  static const GameConfig config = GameConfig.medium;

  /// Bugün oynandı mı?
  static Future<bool> get hasPlayedToday async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('$_playedPrefix$_todayKey') ?? false;
  }

  /// Bugünkü skor (oynandıysa)
  static Future<int?> get todayScore async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('$_scorePrefix$_todayKey');
  }

  /// Oyun sonucunu kaydet
  static Future<void> saveResult(int score) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('$_playedPrefix$_todayKey', true);
    await prefs.setInt('$_scorePrefix$_todayKey', score);
  }

  /// Gece yarısına kalan süreyi biçimlendirilmiş string olarak döndür
  static String countdownToMidnight() {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final diff = tomorrow.difference(now);
    final h = diff.inHours.toString().padLeft(2, '0');
    final m = (diff.inMinutes % 60).toString().padLeft(2, '0');
    final s = (diff.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  /// Bugünün tarihini okunabilir biçimde döndür (örn. "17 Mart 2026")
  static String get todayLabel {
    final now = DateTime.now();
    const months = [
      '', 'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
      'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık',
    ];
    return '${now.day} ${months[now.month]} ${now.year}';
  }
}
