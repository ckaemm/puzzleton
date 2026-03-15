import 'package:flutter/material.dart';
import '../models/game_config.dart';
import '../models/player_score.dart';
import '../services/score_service.dart';
import '../theme/app_theme.dart';
import 'game_screen.dart';
import 'home_screen.dart';
import 'leaderboard_screen.dart';

class ResultScreen extends StatefulWidget {
  final int score;
  final int foundCount;
  final int totalWords;
  final GameConfig config;
  final int timeLeft;
  final String playerName;

  const ResultScreen({
    super.key,
    required this.score,
    required this.foundCount,
    required this.totalWords,
    required this.config,
    required this.timeLeft,
    required this.playerName,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scoreController;
  late Animation<int> _scoreAnim;

  bool get allFound => widget.foundCount >= widget.totalWords;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    _scoreController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _scoreAnim = IntTween(begin: 0, end: widget.score).animate(
      CurvedAnimation(parent: _scoreController, curve: Curves.easeOutCubic),
    );

    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _scoreController.forward();
    });

    // Skoru kaydet
    _saveScore();
  }

  Future<void> _saveScore() async {
    final playerScore = PlayerScore(
      playerName: widget.playerName,
      score: widget.score,
      foundCount: widget.foundCount,
      totalWords: widget.totalWords,
      difficulty: widget.config.label,
      playedAt: DateTime.now(),
    );
    await ScoreService.saveScore(playerScore);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scoreController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final elapsed = widget.config.timeLimitSeconds - widget.timeLeft;
    final minutes = elapsed ~/ 60;
    final seconds = elapsed % 60;
    final timeText =
        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    return Scaffold(
      body: SafeArea(
        child: FadeTransition(
          opacity: CurvedAnimation(
            parent: _fadeController,
            curve: Curves.easeOut,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const Spacer(flex: 2),
                // ── Başlık ──
                Icon(
                  allFound
                      ? Icons.emoji_events_rounded
                      : Icons.hourglass_empty_rounded,
                  size: 72,
                  color: allFound ? AppTheme.gold : AppTheme.textSecondary,
                ),
                const SizedBox(height: 16),
                Text(
                  allFound ? 'Tebrikler!' : 'Süre Doldu!',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: allFound ? AppTheme.gold : AppTheme.textPrimary,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  allFound
                      ? 'Tüm kelimeleri buldun!'
                      : '${widget.foundCount}/${widget.totalWords} kelime buldun',
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const Spacer(),
                // ── Skor ──
                AnimatedBuilder(
                  animation: _scoreAnim,
                  builder: (context, _) {
                    return Text(
                      '${_scoreAnim.value}',
                      style: const TextStyle(
                        fontSize: 64,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.primaryTeal,
                        letterSpacing: 2,
                      ),
                    );
                  },
                ),
                const Text(
                  'PUAN',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryTeal,
                    letterSpacing: 4,
                  ),
                ),
                const Spacer(),
                // ── İstatistikler ──
                _buildStatsCard(timeText),
                const Spacer(),
                // ── Butonlar ──
                _buildButtons(),
                const Spacer(flex: 2),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCard(String timeText) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primaryTeal.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statItem(
            Icons.search_rounded,
            '${widget.foundCount}/${widget.totalWords}',
            'Kelime',
          ),
          Container(width: 1, height: 40, color: AppTheme.cardLight),
          _statItem(
            Icons.timer_outlined,
            timeText,
            'Süre',
          ),
          Container(width: 1, height: 40, color: AppTheme.cardLight),
          _statItem(
            Icons.speed_rounded,
            widget.config.label,
            'Zorluk',
          ),
        ],
      ),
    );
  }

  Widget _statItem(IconData icon, String value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppTheme.primaryTeal, size: 22),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => GameScreen(
                    config: widget.config,
                    playerName: widget.playerName,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.replay_rounded),
            label: const Text('Tekrar Oyna'),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const LeaderboardScreen(),
                ),
              );
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.gold,
              side: BorderSide(color: AppTheme.gold.withValues(alpha: 0.3)),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            icon: const Icon(Icons.emoji_events_rounded),
            label: const Text('Skor Tablosu'),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (_) => HomeScreen(playerName: widget.playerName),
                ),
                (_) => false,
              );
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.textSecondary,
              side: BorderSide(color: AppTheme.textSecondary.withValues(alpha: 0.3)),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            icon: const Icon(Icons.home_rounded),
            label: const Text('Ana Menü'),
          ),
        ),
      ],
    );
  }
}
