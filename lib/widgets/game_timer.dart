import 'package:flutter/material.dart';
import '../services/game_manager.dart';
import '../theme/app_theme.dart';

class GameTimer extends StatelessWidget {
  final GameManager gameManager;

  const GameTimer({super.key, required this.gameManager});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: gameManager,
      builder: (context, _) {
        final total = gameManager.config.timeLimitSeconds;
        final left = gameManager.secondsLeft;
        final ratio = total > 0 ? left / total : 0.0;
        final isLow = left <= 15;

        Color timerColor;
        if (isLow) {
          timerColor = AppTheme.errorRed;
        } else if (ratio < 0.33) {
          timerColor = AppTheme.gold;
        } else {
          timerColor = AppTheme.primaryTeal;
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: AppTheme.cardDark,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: timerColor.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.timer_outlined,
                color: timerColor,
                size: 22,
              ),
              const SizedBox(width: 8),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: isLow ? 22 : 20,
                  fontWeight: FontWeight.bold,
                  color: timerColor,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
                child: Text(gameManager.timerText),
              ),
            ],
          ),
        );
      },
    );
  }
}
