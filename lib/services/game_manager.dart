import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/game_config.dart';
import '../models/placed_word.dart';
import '../services/grid_service.dart';
import '../services/sound_service.dart';
import '../theme/app_theme.dart';

class GameManager extends ChangeNotifier {
  late GameConfig config;
  late List<List<String>> grid;
  late List<PlacedWord> placedWords;

  int _secondsLeft = 0;
  int _score = 0;
  bool _isGameOver = false;
  Timer? _timer;
  int _foundCount = 0;
  int _nextColorIndex = 0;

  // Seçim durumu
  List<CellPosition> selectedCells = [];
  CellPosition? _dragStart;

  // Son bulunan kelime (animasyon için)
  PlacedWord? lastFoundWord;

  // ── İpucu Sistemi ──
  static const int maxHints = 3;
  int _hintsRemaining = maxHints;
  final Set<CellPosition> _hintCells = {};

  int get hintsRemaining => _hintsRemaining;
  Set<CellPosition> get hintCells => _hintCells;

  int get secondsLeft => _secondsLeft;
  int get score => _score;
  bool get isGameOver => _isGameOver;
  int get foundCount => _foundCount;
  int get totalWords => placedWords.length;

  String get timerText {
    final m = _secondsLeft ~/ 60;
    final s = _secondsLeft % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  double get progress => totalWords > 0 ? _foundCount / totalWords : 0;

  /// Oyunu başlat.
  /// [random] verilirse deterministik ızgara oluşturulur (günlük challenge için).
  void startGame(GameConfig gameConfig, {Random? random}) {
    config = gameConfig;
    _secondsLeft = config.timeLimitSeconds;
    _score = 0;
    _isGameOver = false;
    _foundCount = 0;
    _nextColorIndex = 0;
    _hintsRemaining = maxHints;
    _hintCells.clear();
    selectedCells = [];
    _dragStart = null;
    lastFoundWord = null;

    // Izgara oluştur
    final result = GridService.generateGrid(config, random: random);
    grid = result.grid;
    placedWords = result.placedWords;

    // Zamanlayıcıyı başlat
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_secondsLeft > 0) {
        _secondsLeft--;

        // Son 10 saniye tick sesi
        if (_secondsLeft <= 10 && _secondsLeft > 0) {
          SoundService.playTick();
        }

        notifyListeners();
        if (_secondsLeft == 0) {
          _endGame(won: false);
        }
      }
    });

    notifyListeners();
  }

  /// ── İpucu Kullan ──
  bool useHint() {
    if (_isGameOver || _hintsRemaining <= 0) return false;

    // Bulunmamış kelimeleri al
    final unfound = placedWords.where((pw) => !pw.found).toList();
    if (unfound.isEmpty) return false;

    final random = Random();
    // Rastgele bir kelime seç
    final word = unfound[random.nextInt(unfound.length)];

    // Bu kelimenin henüz ipucu verilmemiş hücrelerini bul
    final unhintedCells = word.positions
        .where((pos) => !_hintCells.contains(pos))
        .toList();

    if (unhintedCells.isEmpty) {
      // Bu kelimenin tüm harfleri zaten ipucu — başka kelime dene
      for (var w in unfound) {
        final cells = w.positions.where((p) => !_hintCells.contains(p)).toList();
        if (cells.isNotEmpty) {
          _hintCells.add(cells[random.nextInt(cells.length)]);
          _hintsRemaining--;
          SoundService.playHint();
          notifyListeners();
          return true;
        }
      }
      return false;
    }

    _hintCells.add(unhintedCells[random.nextInt(unhintedCells.length)]);
    _hintsRemaining--;
    SoundService.playHint();
    notifyListeners();
    return true;
  }

  /// Hücrenin ipucu hücresi olup olmadığını kontrol et
  bool isHintCell(int row, int col) {
    return _hintCells.contains(CellPosition(row, col));
  }

  /// Sürükleme başlangıcı
  void onDragStart(int row, int col) {
    if (_isGameOver) return;
    _dragStart = CellPosition(row, col);
    selectedCells = [CellPosition(row, col)];
    SoundService.playSelect();
    notifyListeners();
  }

  /// Sürükleme devam
  void onDragUpdate(int currentRow, int currentCol) {
    if (_isGameOver || _dragStart == null) return;

    final startR = _dragStart!.row;
    final startC = _dragStart!.col;
    final dr = currentRow - startR;
    final dc = currentCol - startC;

    if (dr == 0 && dc == 0) {
      selectedCells = [CellPosition(startR, startC)];
      notifyListeners();
      return;
    }

    // Yönü belirle (en yakın 45 dereceye snap)
    int stepR, stepC;
    if (dc == 0) {
      stepR = dr > 0 ? 1 : -1;
      stepC = 0;
    } else if (dr == 0) {
      stepR = 0;
      stepC = dc > 0 ? 1 : -1;
    } else if (dr.abs() > dc.abs() * 2) {
      stepR = dr > 0 ? 1 : -1;
      stepC = 0;
    } else if (dc.abs() > dr.abs() * 2) {
      stepR = 0;
      stepC = dc > 0 ? 1 : -1;
    } else {
      stepR = dr > 0 ? 1 : -1;
      stepC = dc > 0 ? 1 : -1;
    }

    // Adım sayısı
    int steps;
    if (stepR != 0 && stepC != 0) {
      steps = (dr.abs() + dc.abs()) ~/ 2;
    } else if (stepR != 0) {
      steps = dr.abs();
    } else {
      steps = dc.abs();
    }

    // Hücreleri seç
    List<CellPosition> cells = [];
    for (int i = 0; i <= steps; i++) {
      int r = startR + i * stepR;
      int c = startC + i * stepC;
      if (r >= 0 && r < config.gridSize && c >= 0 && c < config.gridSize) {
        cells.add(CellPosition(r, c));
      } else {
        break;
      }
    }

    selectedCells = cells;
    notifyListeners();
  }

  /// Sürükleme bitişi
  bool onDragEnd() {
    if (_isGameOver || selectedCells.isEmpty) {
      selectedCells = [];
      _dragStart = null;
      notifyListeners();
      return false;
    }

    // Seçilen harfleri birleştir
    String selectedWord = selectedCells.map((p) => grid[p.row][p.col]).join();

    // Kelimeyi kontrol et
    bool found = false;
    for (var pw in placedWords) {
      if (!pw.found && pw.word == selectedWord) {
        pw.found = true;
        pw.colorIndex = _nextColorIndex % AppTheme.wordColors.length;
        _nextColorIndex++;
        _foundCount++;
        lastFoundWord = pw;

        // Bu kelimenin ipucu hücrelerini temizle
        for (var pos in pw.positions) {
          _hintCells.remove(pos);
        }

        // Skor hesapla
        int wordScore = pw.word.length * 10;
        _score += (wordScore * config.scoreMultiplier).round();

        SoundService.playWordFound();
        found = true;
        break;
      }
    }

    if (!found && selectedCells.length > 1) {
      SoundService.playWrongSelection();
    }

    selectedCells = [];
    _dragStart = null;

    // Tüm kelimeler bulundu mu?
    if (_foundCount >= totalWords) {
      // Süre bonusu
      _score += (_secondsLeft * 2 * config.scoreMultiplier).round();
      _endGame(won: true);
    }

    notifyListeners();
    return found;
  }

  /// Hücrenin bulunan kelimeye ait olup olmadığını ve rengini döndürür
  int? getFoundColorIndex(int row, int col) {
    for (var pw in placedWords) {
      if (pw.found && pw.positions.any((p) => p.row == row && p.col == col)) {
        return pw.colorIndex;
      }
    }
    return null;
  }

  void _endGame({required bool won}) {
    _isGameOver = true;
    _timer?.cancel();

    if (won) {
      SoundService.playGameWon();
    } else {
      SoundService.playGameLost();
    }

    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
