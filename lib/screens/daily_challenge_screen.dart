import 'dart:async';
import 'package:flutter/material.dart';
import '../services/daily_challenge_service.dart';
import '../services/game_manager.dart';
import '../services/sound_service.dart';
import '../theme/app_theme.dart';
import '../widgets/game_timer.dart';
import '../widgets/puzzle_grid.dart';
import '../widgets/word_list_panel.dart';

class DailyChallengeScreen extends StatefulWidget {
  final String playerName;

  const DailyChallengeScreen({super.key, required this.playerName});

  @override
  State<DailyChallengeScreen> createState() => _DailyChallengeScreenState();
}

class _DailyChallengeScreenState extends State<DailyChallengeScreen>
    with TickerProviderStateMixin {
  // ── Yükleme / Durum ──
  bool _isLoading = true;
  bool _hasPlayed = false;
  int? _completedScore;
  int? _completedFound;

  // ── Oyun ──
  GameManager? _gameManager;
  bool _hasSaved = false;

  // ── Skor pop animasyonu ──
  late AnimationController _scorePopController;
  late Animation<double> _scorePopAnim;

  // ── Tamamlandı ekranı animasyonu ──
  late AnimationController _completedFadeController;

  // ── Geri sayım zamanlayıcısı ──
  Timer? _countdownTimer;
  String _countdown = DailyChallengeService.countdownToMidnight();

  @override
  void initState() {
    super.initState();

    _scorePopController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _scorePopAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.4), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.4, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _scorePopController, curve: Curves.easeOut));

    _completedFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _loadStatus();
  }

  Future<void> _loadStatus() async {
    final played = await DailyChallengeService.hasPlayedToday;
    final score = await DailyChallengeService.todayScore;

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      _hasPlayed = played;
      _completedScore = score;
    });

    if (played) {
      _completedFadeController.forward();
      _startCountdown();
    } else {
      _initGame();
    }
  }

  void _initGame() {
    _gameManager = GameManager();
    _gameManager!.startGame(
      DailyChallengeService.config,
      random: DailyChallengeService.todayRandom,
    );
    _gameManager!.addListener(_checkGameOver);
  }

  void _checkGameOver() async {
    final gm = _gameManager;
    if (gm == null || !gm.isGameOver || _hasSaved) return;

    _hasSaved = true;
    await DailyChallengeService.saveResult(gm.score);

    if (!mounted) return;

    // 600ms bekle (oyun sonu efekti)
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;

    setState(() {
      _hasPlayed = true;
      _completedScore = gm.score;
      _completedFound = gm.foundCount;
    });
    _completedFadeController.forward();
    _startCountdown();
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _countdown = DailyChallengeService.countdownToMidnight();
        });
      }
    });
  }

  void _onWordFound() => _scorePopController.forward(from: 0);

  @override
  void dispose() {
    _gameManager?.removeListener(_checkGameOver);
    _gameManager?.dispose();
    _scorePopController.dispose();
    _completedFadeController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  // ── BUILD ──

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return _buildLoading();
    if (_hasPlayed) return _buildCompleted();
    return _buildGame();
  }

  // ── Yükleniyor ──
  Widget _buildLoading() {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(color: AppTheme.primaryTeal),
      ),
    );
  }

  // ── Oyun ekranı ──
  Widget _buildGame() {
    final gm = _gameManager!;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
          child: Column(
            children: [
              _buildGameTopBar(gm),
              const SizedBox(height: 6),
              _buildProgressBar(gm),
              const SizedBox(height: 6),
              _buildActionBar(gm),
              const SizedBox(height: 8),
              Expanded(
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: PuzzleGrid(
                      gameManager: gm,
                      onWordFound: _onWordFound,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              WordListPanel(gameManager: gm),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGameTopBar(GameManager gm) {
    return Row(
      children: [
        IconButton(
          onPressed: _showExitDialog,
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
          color: AppTheme.textSecondaryColor(context),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
        ),
        // Günlük Challenge etiketi
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppTheme.primaryTeal, AppTheme.darkTeal],
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.calendar_today_rounded,
                  size: 12, color: Colors.white),
              const SizedBox(width: 4),
              Text(
                DailyChallengeService.todayLabel,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        // Skor
        ListenableBuilder(
          listenable: gm,
          builder: (context, _) {
            return ScaleTransition(
              scale: _scorePopAnim,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                      '${gm.score}',
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
        GameTimer(gameManager: gm),
      ],
    );
  }

  Widget _buildProgressBar(GameManager gm) {
    return ListenableBuilder(
      listenable: gm,
      builder: (context, _) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: gm.progress,
            minHeight: 4,
            backgroundColor: AppTheme.cardSurface(context),
            valueColor:
                const AlwaysStoppedAnimation<Color>(AppTheme.primaryTeal),
          ),
        );
      },
    );
  }

  Widget _buildActionBar(GameManager gm) {
    return ListenableBuilder(
      listenable: gm,
      builder: (context, _) {
        final hasHints = gm.hintsRemaining > 0;
        return Row(
          children: [
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: hasHints ? () => gm.useHint() : null,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: hasHints
                        ? AppTheme.gold.withValues(alpha: 0.12)
                        : AppTheme.cardSurface(context).withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: hasHints
                          ? AppTheme.gold.withValues(alpha: 0.3)
                          : Colors.transparent,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.lightbulb_rounded,
                          size: 18,
                          color: hasHints
                              ? AppTheme.gold
                              : AppTheme.textSecondaryColor(context)),
                      const SizedBox(width: 6),
                      Text(
                        'İpucu (${gm.hintsRemaining})',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: hasHints
                              ? AppTheme.gold
                              : AppTheme.textSecondaryColor(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const Spacer(),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  SoundService.toggle();
                  setState(() {});
                },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  decoration: BoxDecoration(
                    color:
                        AppTheme.cardSurface(context).withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    SoundService.enabled
                        ? Icons.volume_up_rounded
                        : Icons.volume_off_rounded,
                    size: 20,
                    color: SoundService.enabled
                        ? AppTheme.primaryTeal
                        : AppTheme.textSecondaryColor(context),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardColor(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Çıkmak İstiyor musun?',
            style: TextStyle(color: AppTheme.textPrimaryColor(context))),
        content: Text(
          'Günlük challenge yarın sıfırlanır. Bugün sadece bir kez oynanabilir.',
          style: TextStyle(color: AppTheme.textSecondaryColor(context)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Devam Et'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: Text('Çık',
                style: TextStyle(color: AppTheme.errorRed)),
          ),
        ],
      ),
    );
  }

  // ── Tamamlandı ekranı ──
  Widget _buildCompleted() {
    final totalWords = _gameManager?.totalWords ??
        DailyChallengeService.config.wordCount;
    final found = _completedFound ?? totalWords;

    return Scaffold(
      body: SafeArea(
        child: FadeTransition(
          opacity: CurvedAnimation(
            parent: _completedFadeController,
            curve: Curves.easeOut,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const Spacer(flex: 2),
                // ── Rozet ──
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppTheme.primaryTeal, AppTheme.darkTeal],
                    ),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryTeal.withValues(alpha: 0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.calendar_today_rounded,
                    size: 48,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Günlük Challenge',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondaryColor(context),
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tamamlandı!',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.textPrimaryColor(context),
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DailyChallengeService.todayLabel,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.primaryTeal,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                // ── Skor kartı ──
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppTheme.cardColor(context),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppTheme.primaryTeal.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${_completedScore ?? 0}',
                        style: const TextStyle(
                          fontSize: 56,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.primaryTeal,
                          letterSpacing: 2,
                        ),
                      ),
                      const Text(
                        'PUAN',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryTeal,
                          letterSpacing: 4,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        height: 1,
                        color: AppTheme.cardSurface(context),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.search_rounded,
                              size: 18, color: AppTheme.primaryTeal),
                          const SizedBox(width: 6),
                          Text(
                            '$found / $totalWords kelime',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimaryColor(context),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                // ── Sonraki challenge geri sayımı ──
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppTheme.cardColor(context),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.access_time_rounded,
                          size: 18,
                          color: AppTheme.textSecondaryColor(context)),
                      const SizedBox(width: 8),
                      Text(
                        'Sonraki challenge: ',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.textSecondaryColor(context),
                        ),
                      ),
                      Text(
                        _countdown,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryTeal,
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(flex: 2),
                // ── Ana Menü butonu ──
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryTeal,
                      side: BorderSide(
                          color: AppTheme.primaryTeal.withValues(alpha: 0.4)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    icon: const Icon(Icons.home_rounded),
                    label: const Text('Ana Menü'),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
