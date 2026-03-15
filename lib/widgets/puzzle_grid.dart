import 'package:flutter/material.dart';
import '../models/placed_word.dart';
import '../services/game_manager.dart';
import '../theme/app_theme.dart';

class PuzzleGrid extends StatefulWidget {
  final GameManager gameManager;
  final VoidCallback onWordFound;

  const PuzzleGrid({
    super.key,
    required this.gameManager,
    required this.onWordFound,
  });

  @override
  State<PuzzleGrid> createState() => _PuzzleGridState();
}

class _PuzzleGridState extends State<PuzzleGrid>
    with TickerProviderStateMixin {
  final GlobalKey _gridKey = GlobalKey();
  double _cellSize = 0;

  // Animasyon: yeni bulunan hücreler için
  AnimationController? _foundAnimController;
  Animation<double>? _foundScaleAnim;
  Set<CellPosition> _animatingCells = {};

  // İpucu hücreleri nabız animasyonu
  late AnimationController _hintPulseController;
  late Animation<double> _hintPulseAnim;

  GameManager get gm => widget.gameManager;

  @override
  void initState() {
    super.initState();
    _hintPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _hintPulseAnim = Tween<double>(begin: 0.3, end: 0.9).animate(
      CurvedAnimation(parent: _hintPulseController, curve: Curves.easeInOut),
    );
    _hintPulseController.addListener(() {
      if (mounted && gm.hintCells.isNotEmpty) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _foundAnimController?.dispose();
    _hintPulseController.dispose();
    super.dispose();
  }

  CellPosition? _getCellFromPosition(Offset globalPosition) {
    final RenderBox? box =
        _gridKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return null;

    final local = box.globalToLocal(globalPosition);
    final row = (local.dy / _cellSize).floor();
    final col = (local.dx / _cellSize).floor();
    final gridSize = gm.config.gridSize;

    if (row >= 0 && row < gridSize && col >= 0 && col < gridSize) {
      return CellPosition(row, col);
    }
    return null;
  }

  void _onPanStart(DragStartDetails details) {
    final cell = _getCellFromPosition(details.globalPosition);
    if (cell != null) {
      gm.onDragStart(cell.row, cell.col);
    }
  }

  void _onPanUpdate(DragUpdateDetails details) {
    final cell = _getCellFromPosition(details.globalPosition);
    if (cell != null) {
      gm.onDragUpdate(cell.row, cell.col);
    }
  }

  void _onPanEnd(DragEndDetails details) {
    final found = gm.onDragEnd();
    if (found && gm.lastFoundWord != null) {
      _playFoundAnimation(gm.lastFoundWord!.positions.toSet());
      widget.onWordFound();
    }
  }

  void _playFoundAnimation(Set<CellPosition> cells) {
    _foundAnimController?.dispose();
    _foundAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _foundScaleAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.3), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 0.9), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.9, end: 1.0), weight: 30),
    ]).animate(CurvedAnimation(
      parent: _foundAnimController!,
      curve: Curves.easeOut,
    ));

    _animatingCells = cells;
    _foundAnimController!.forward().then((_) {
      if (mounted) {
        setState(() => _animatingCells = {});
      }
    });
    _foundAnimController!.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: gm,
      builder: (context, _) {
        final gridSize = gm.config.gridSize;

        return LayoutBuilder(
          builder: (context, constraints) {
            _cellSize = constraints.maxWidth / gridSize;

            return GestureDetector(
              onPanStart: _onPanStart,
              onPanUpdate: _onPanUpdate,
              onPanEnd: _onPanEnd,
              child: Container(
                key: _gridKey,
                width: constraints.maxWidth,
                height: constraints.maxWidth,
                decoration: BoxDecoration(
                  color: AppTheme.cardDark,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.primaryTeal.withValues(alpha: 0.2),
                    width: 1.5,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(11),
                  child: Column(
                    children: List.generate(gridSize, (row) {
                      return Expanded(
                        child: Row(
                          children: List.generate(gridSize, (col) {
                            return Expanded(
                              child: _buildCell(row, col),
                            );
                          }),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCell(int row, int col) {
    final letter = gm.grid[row][col];
    final cellPos = CellPosition(row, col);
    final isSelected = gm.selectedCells.contains(cellPos);
    final foundColorIdx = gm.getFoundColorIndex(row, col);
    final isFound = foundColorIdx != null;
    final isAnimating = _animatingCells.contains(cellPos);
    final isHint = gm.isHintCell(row, col);

    Color bgColor;
    Color textColor;

    if (isSelected) {
      bgColor = AppTheme.primaryTeal.withValues(alpha: 0.4);
      textColor = Colors.white;
    } else if (isFound) {
      final wordColor = AppTheme.wordColors[foundColorIdx % AppTheme.wordColors.length];
      bgColor = wordColor.withValues(alpha: 0.3);
      textColor = wordColor;
    } else if (isHint) {
      final pulseVal = _hintPulseAnim.value;
      bgColor = AppTheme.gold.withValues(alpha: pulseVal * 0.3);
      textColor = AppTheme.gold;
    } else {
      bgColor = Colors.transparent;
      textColor = AppTheme.textPrimary.withValues(alpha: 0.85);
    }

    double scale = 1.0;
    if (isAnimating && _foundScaleAnim != null) {
      scale = _foundScaleAnim!.value;
    }

    return Transform.scale(
      scale: scale,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(
            color: isHint
                ? AppTheme.gold.withValues(alpha: _hintPulseAnim.value * 0.5)
                : AppTheme.cardLight.withValues(alpha: 0.3),
            width: isHint ? 1.5 : 0.5,
          ),
        ),
        child: Center(
          child: Text(
            letter,
            style: TextStyle(
              fontSize: _cellSize * 0.48,
              fontWeight: isFound || isSelected || isHint
                  ? FontWeight.w800
                  : FontWeight.w500,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}
