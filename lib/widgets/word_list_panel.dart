import 'package:flutter/material.dart';
import '../services/game_manager.dart';
import '../theme/app_theme.dart';

class WordListPanel extends StatelessWidget {
  final GameManager gameManager;

  const WordListPanel({super.key, required this.gameManager});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: gameManager,
      builder: (context, _) {
        // Kelimeleri kategoriye göre grupla
        final Map<String, List<_WordItem>> grouped = {};
        for (var pw in gameManager.placedWords) {
          grouped.putIfAbsent(pw.category, () => []);
          Color? color;
          if (pw.found && pw.colorIndex != null) {
            color =
                AppTheme.wordColors[pw.colorIndex! % AppTheme.wordColors.length];
          }
          grouped[pw.category]!.add(_WordItem(
            word: pw.word,
            found: pw.found,
            color: color,
          ));
        }

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.cardDark,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.primaryTeal.withValues(alpha: 0.15),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(Icons.search, color: AppTheme.primaryTeal, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    'Kelimeler (${gameManager.foundCount}/${gameManager.totalWords})',
                    style: const TextStyle(
                      color: AppTheme.primaryTeal,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: gameManager.placedWords.map((pw) {
                  final found = pw.found;
                  Color chipColor;
                  if (found && pw.colorIndex != null) {
                    chipColor = AppTheme
                        .wordColors[pw.colorIndex! % AppTheme.wordColors.length];
                  } else {
                    chipColor = AppTheme.textSecondary;
                  }

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: found
                          ? chipColor.withValues(alpha: 0.2)
                          : AppTheme.cardLight.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color:
                            found ? chipColor.withValues(alpha: 0.5) : Colors.transparent,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      pw.word,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: found ? FontWeight.bold : FontWeight.w400,
                        color: found ? chipColor : AppTheme.textSecondary,
                        decoration: found ? TextDecoration.lineThrough : null,
                        decorationColor: chipColor,
                        decorationThickness: 2,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _WordItem {
  final String word;
  final bool found;
  final Color? color;

  _WordItem({required this.word, required this.found, this.color});
}
