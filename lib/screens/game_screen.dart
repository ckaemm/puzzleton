import 'package:flutter/material.dart';
import '../models/game_config.dart';
import '../services/game_manager.dart';
import '../services/sound_service.dart';
import '../theme/app_theme.dart';
import '../widgets/puzzle_grid.dart';
import '../widgets/word_list_panel.dart';
import '../widgets/game_timer.dart';
import 'result_screen.dart';

class GameScreen extends StatefulWidget {
  final GameConfig config;
  final String playerName;

  const GameScreen({
    super.key,
    required this.config,
    required this.playerName,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  late GameManager _gameManager;
  late AnimationController _scorePopController;
  late Animation<double> _scorePopAnim;
  bool _navigatedToResult = false;

  @override
  void initState() {
    super.initState();
    _gameManager = GameManager();
    _gameManager.startGame(widget.config);
    _gameManager.addListener(_checkGameOver);

    _scorePopController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _scorePopAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.4), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.4, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(
      parent: _scorePopController,
      curve: Curves.easeOut,
    ));
  }

  void _checkGameOver() {
    if (_gameManager.isGameOver && !_navigatedToResult) {
      _navigatedToResult = true;
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => ResultScreen(
                score: _gameManager.score,
                foundCount: _gameManager.foundCount,
                totalWords: _gameManager.totalWords,
                config: widget.config,
                timeLeft: _gameManager.secondsLeft,
                playerName: widget.playerName,
              ),
              transitionsBuilder: (_, anim, __, child) {
                return FadeTransition(opacity: anim, child: child);
              },
              transitionDuration: const Duration(milliseconds: 500),
            ),
          );
        }
      });
    }
  }

  void _onWordFound() {
    _scorePopController.forward(from: 0);
  }

  @override
  void dispose() {
    _gameManager.removeListener(_checkGameOver);
    _gameManager.dispose();
    _scorePopController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
          child: Column(
            children: [
              // ── Üst Bar ──
              _buildTopBar(),
              const SizedBox(height: 6),
              // ── İlerleme Çubuğu ──
              _buildProgressBar(),
              const SizedBox(height: 6),
              // ── Aksiyonlar: İpucu + Ses ──
              _buildActionBar(),
              const SizedBox(height: 8),
              // ── Izgara ──
              Expanded(
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: PuzzleGrid(
                      gameManager: _gameManager,
                      onWordFound: _onWordFound,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // ── Kelime Listesi ──
              WordListPanel(gameManager: _gameManager),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      children: [
        // Geri butonu
        IconButton(
          onPressed: () => _showExitDialog(),
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
          color: AppTheme.textSecondary,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
        ),
        // Zorluk etiketi
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppTheme.primaryTeal.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            widget.config.label,
            style: const TextStyle(
              color: AppTheme.primaryTeal,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
        const Spacer(),
        // Skor
        ListenableBuilder(
          listenable: _gameManager,
          builder: (context, _) {
            return ScaleTransition(
              scale: _scorePopAnim,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.gold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star_rounded,
                        color: AppTheme.gold, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      '${_gameManager.score}',
                      style: const TextStyle(
                        color: AppTheme.gold,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(width: 8),
        // Zamanlayıcı
        GameTimer(gameManager: _gameManager),
      ],
    );
  }

  Widget _buildActionBar() {
    return ListenableBuilder(
      listenable: _gameManager,
      builder: (context, _) {
        return Row(
          children: [
            // İpucu Butonu
            _HintButton(
              hintsRemaining: _gameManager.hintsRemaining,
              onTap: () {
                _gameManager.useHint();
              },
            ),
            const Spacer(),
            // Ses Aç/Kapa
            _SoundToggle(),
          ],
        );
      },
    );
  }

  Widget _buildProgressBar() {
    return ListenableBuilder(
      listenable: _gameManager,
      builder: (context, _) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: _gameManager.progress,
            minHeight: 4,
            backgroundColor: AppTheme.cardLight,
            valueColor:
                const AlwaysStoppedAnimation<Color>(AppTheme.primaryTeal),
          ),
        );
      },
    );
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Oyundan Çık',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        content: const Text(
          'Oyundan çıkmak istediğine emin misin? İlerleme kaydedilmez.',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('Çık', style: TextStyle(color: AppTheme.errorRed)),
          ),
        ],
      ),
    );
  }
}

// ── İpucu Butonu ──
class _HintButton extends StatelessWidget {
  final int hintsRemaining;
  final VoidCallback onTap;

  const _HintButton({required this.hintsRemaining, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final hasHints = hintsRemaining > 0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: hasHints ? onTap : null,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: hasHints
                ? AppTheme.gold.withValues(alpha: 0.12)
                : AppTheme.cardLight.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: hasHints
                  ? AppTheme.gold.withValues(alpha: 0.3)
                  : Colors.transparent,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.lightbulb_rounded,
                size: 18,
                color: hasHints ? AppTheme.gold : AppTheme.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                'İpucu ($hintsRemaining)',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: hasHints ? AppTheme.gold : AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Ses Aç/Kapa Butonu ──
class _SoundToggle extends StatefulWidget {
  @override
  State<_SoundToggle> createState() => _SoundToggleState();
}

class _SoundToggleState extends State<_SoundToggle> {
  @override
  Widget build(BuildContext context) {
    final isOn = SoundService.enabled;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          SoundService.toggle();
          setState(() {});
        },
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: AppTheme.cardLight.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            isOn ? Icons.volume_up_rounded : Icons.volume_off_rounded,
            size: 20,
            color: isOn ? AppTheme.primaryTeal : AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }
}
