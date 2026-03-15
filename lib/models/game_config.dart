enum Difficulty { easy, medium, hard }

class GameConfig {
  final Difficulty difficulty;
  final int gridSize;
  final int wordCount;
  final int timeLimitSeconds;
  final double scoreMultiplier;
  final String label;

  const GameConfig._({
    required this.difficulty,
    required this.gridSize,
    required this.wordCount,
    required this.timeLimitSeconds,
    required this.scoreMultiplier,
    required this.label,
  });

  static const GameConfig easy = GameConfig._(
    difficulty: Difficulty.easy,
    gridSize: 10,
    wordCount: 6,
    timeLimitSeconds: 180,
    scoreMultiplier: 1.0,
    label: 'Kolay',
  );

  static const GameConfig medium = GameConfig._(
    difficulty: Difficulty.medium,
    gridSize: 10,
    wordCount: 10,
    timeLimitSeconds: 120,
    scoreMultiplier: 1.5,
    label: 'Orta',
  );

  static const GameConfig hard = GameConfig._(
    difficulty: Difficulty.hard,
    gridSize: 12,
    wordCount: 14,
    timeLimitSeconds: 60,
    scoreMultiplier: 2.0,
    label: 'Zor',
  );

  static const List<GameConfig> all = [easy, medium, hard];
}
