import 'package:flutter/material.dart';
import '../models/game_config.dart';
import '../theme/app_theme.dart';
import 'game_screen.dart';
import 'leaderboard_screen.dart';

class HomeScreen extends StatefulWidget {
  final String playerName;

  const HomeScreen({super.key, required this.playerName});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _titleController;
  late Animation<double> _titleFade;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _titleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _titleFade = CurvedAnimation(
      parent: _titleController,
      curve: Curves.easeOut,
    );
    _titleController.forward();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _startGame(GameConfig config) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => GameScreen(
          config: config,
          playerName: widget.playerName,
        ),
        transitionsBuilder: (_, anim, __, child) {
          return FadeTransition(opacity: anim, child: child);
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(flex: 2),
              // ── Logo & Başlık ──
              FadeTransition(
                opacity: _titleFade,
                child: Column(
                  children: [
                    ScaleTransition(
                      scale: _pulseAnim,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryTeal.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: AppTheme.primaryTeal.withValues(alpha: 0.5),
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.grid_on_rounded,
                          size: 52,
                          color: AppTheme.primaryTeal,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'PUZZLETON',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 6,
                        color: AppTheme.primaryTeal,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Türkçe Kelime Bul',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppTheme.textSecondary,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryTeal.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Hoş geldin, ${widget.playerName}!',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.lightTeal,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(flex: 2),
              // ── Zorluk Seçimi ──
              FadeTransition(
                opacity: _titleFade,
                child: Column(
                  children: [
                    const Text(
                      'Zorluk Seviyesi Seç',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ...GameConfig.all.map((config) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _DifficultyCard(
                            config: config,
                            onTap: () => _startGame(config),
                          ),
                        )),
                  ],
                ),
              ),
              const Spacer(flex: 2),
              // ── Liderlik Tablosu Butonu ──
              FadeTransition(
                opacity: _titleFade,
                child: TextButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const LeaderboardScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.emoji_events_rounded,
                      color: AppTheme.gold, size: 20),
                  label: const Text(
                    'Skor Tablosu',
                    style: TextStyle(
                      color: AppTheme.gold,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _DifficultyCard extends StatelessWidget {
  final GameConfig config;
  final VoidCallback onTap;

  const _DifficultyCard({required this.config, required this.onTap});

  IconData get _icon {
    switch (config.difficulty) {
      case Difficulty.easy:
        return Icons.sentiment_satisfied_rounded;
      case Difficulty.medium:
        return Icons.sentiment_neutral_rounded;
      case Difficulty.hard:
        return Icons.local_fire_department_rounded;
    }
  }

  Color get _accentColor {
    switch (config.difficulty) {
      case Difficulty.easy:
        return const Color(0xFF66BB6A);
      case Difficulty.medium:
        return const Color(0xFFFFCA28);
      case Difficulty.hard:
        return const Color(0xFFEF5350);
    }
  }

  @override
  Widget build(BuildContext context) {
    final minutes = config.timeLimitSeconds ~/ 60;
    final seconds = config.timeLimitSeconds % 60;
    final timeText = seconds > 0 ? '$minutes dk $seconds sn' : '$minutes dk';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: AppTheme.cardDark,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _accentColor.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Icon(_icon, color: _accentColor, size: 32),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      config.label,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _accentColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${config.wordCount} kelime · $timeText · ${config.gridSize}×${config.gridSize}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: _accentColor.withValues(alpha: 0.6),
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
