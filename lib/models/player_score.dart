import 'dart:convert';

class PlayerScore {
  final String playerName;
  final int score;
  final int foundCount;
  final int totalWords;
  final String difficulty;
  final DateTime playedAt;

  PlayerScore({
    required this.playerName,
    required this.score,
    required this.foundCount,
    required this.totalWords,
    required this.difficulty,
    required this.playedAt,
  });

  Map<String, dynamic> toJson() => {
        'playerName': playerName,
        'score': score,
        'foundCount': foundCount,
        'totalWords': totalWords,
        'difficulty': difficulty,
        'playedAt': playedAt.toIso8601String(),
      };

  factory PlayerScore.fromJson(Map<String, dynamic> json) => PlayerScore(
        playerName: json['playerName'] as String,
        score: json['score'] as int,
        foundCount: json['foundCount'] as int,
        totalWords: json['totalWords'] as int,
        difficulty: json['difficulty'] as String,
        playedAt: DateTime.parse(json['playedAt'] as String),
      );

  static String encodeList(List<PlayerScore> scores) =>
      jsonEncode(scores.map((s) => s.toJson()).toList());

  static List<PlayerScore> decodeList(String jsonStr) {
    final List<dynamic> list = jsonDecode(jsonStr) as List<dynamic>;
    return list
        .map((e) => PlayerScore.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
