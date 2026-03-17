import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/score_service.dart';
import '../models/player_score.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  List<PlayerScore> _scores = [];
  bool _isLoading = true;
  late AnimationController _listAnimController;

  @override
  void initState() {
    super.initState();
    _listAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _loadScores();
  }

  Future<void> _loadScores() async {
    final scores = await ScoreService.getTopScores(limit: 20);
    if (mounted) {
      setState(() {
        _scores = scores;
        _isLoading = false;
      });
      _listAnimController.forward();
    }
  }

  Future<void> _confirmClearScores() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardColor(ctx),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Skorları Sil',
          style: TextStyle(color: AppTheme.textPrimaryColor(ctx)),
        ),
        content: Text(
          'Tüm skor kayıtlarını silmek istediğine emin misin?',
          style: TextStyle(color: AppTheme.textSecondaryColor(ctx)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sil', style: TextStyle(color: AppTheme.errorRed)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ScoreService.clearScores();
      _loadScores();
    }
  }

  @override
  void dispose() {
    _listAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Skor Tablosu'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_scores.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded,
                  color: AppTheme.textSecondary),
              onPressed: _confirmClearScores,
              tooltip: 'Skorları Sil',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryTeal),
            )
          : _scores.isEmpty
              ? _buildEmptyState()
              : _buildScoreList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.emoji_events_outlined,
            size: 72,
            color: AppTheme.textSecondaryColor(context).withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            'Henüz skor yok',
            style: TextStyle(
              fontSize: 18,
              color: AppTheme.textSecondaryColor(context),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Oyun oynayarak skor tablosunu doldur!',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondaryColor(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreList() {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: _listAnimController,
        curve: Curves.easeOut,
      ),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        itemCount: _scores.length,
        itemBuilder: (context, index) {
          final score = _scores[index];
          return _ScoreRow(
            rank: index + 1,
            score: score,
            delay: index * 60,
          );
        },
      ),
    );
  }
}

class _ScoreRow extends StatelessWidget {
  final int rank;
  final PlayerScore score;
  final int delay;

  const _ScoreRow({
    required this.rank,
    required this.score,
    required this.delay,
  });

  Color get _rankColor {
    switch (rank) {
      case 1:
        return const Color(0xFFFFD54F); // Altın
      case 2:
        return const Color(0xFFB0BEC5); // Gümüş
      case 3:
        return const Color(0xFFFF8A65); // Bronz
      default:
        return AppTheme.textSecondary;
    }
  }

  IconData? get _rankIcon {
    if (rank <= 3) return Icons.emoji_events_rounded;
    return null;
  }

  String get _difficultyEmoji {
    switch (score.difficulty) {
      case 'Kolay':
        return '🟢';
      case 'Orta':
        return '🟡';
      case 'Zor':
        return '🔴';
      default:
        return '';
    }
  }

  String get _timeAgo {
    final now = DateTime.now();
    final diff = now.difference(score.playedAt);

    if (diff.inMinutes < 1) return 'Az önce';
    if (diff.inMinutes < 60) return '${diff.inMinutes} dk önce';
    if (diff.inHours < 24) return '${diff.inHours} saat önce';
    if (diff.inDays < 7) return '${diff.inDays} gün önce';

    return '${score.playedAt.day}.${score.playedAt.month}.${score.playedAt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: rank <= 3
            ? _rankColor.withValues(alpha: 0.08)
            : AppTheme.cardColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: rank <= 3
              ? _rankColor.withValues(alpha: 0.25)
              : AppTheme.cardSurface(context).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Sıralama
          SizedBox(
            width: 36,
            child: _rankIcon != null
                ? Icon(_rankIcon, color: _rankColor, size: 24)
                : Text(
                    '#$rank',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: _rankColor,
                    ),
                  ),
          ),
          const SizedBox(width: 10),
          // Oyuncu bilgisi
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  score.playerName,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: rank <= 3 ? _rankColor : AppTheme.textPrimaryColor(context),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$_difficultyEmoji ${score.difficulty} · ${score.foundCount}/${score.totalWords} kelime · $_timeAgo',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppTheme.textSecondaryColor(context),
                  ),
                ),
              ],
            ),
          ),
          // Skor
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.primaryTeal.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${score.score}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: AppTheme.primaryTeal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
