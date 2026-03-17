import 'dart:math';
import '../constants/word_data.dart';
import '../models/placed_word.dart';
import '../models/game_config.dart';

class GridResult {
  final List<List<String>> grid;
  final List<PlacedWord> placedWords;

  GridResult({required this.grid, required this.placedWords});
}

class GridService {
  static final _random = Random();

  /// 4 yön (ters yönler hariç): [dr, dc]
  static const List<List<int>> _directions = [
    [0, 1], // sağ
    [1, 0], // aşağı
    [1, 1], // sağ-aşağı çapraz
    [1, -1], // sol-aşağı çapraz
  ];

  /// Verilen config'e göre ızgara oluşturur.
  /// [random] verilirse deterministik (günlük challenge için), verilmezse rastgele.
  static GridResult generateGrid(GameConfig config, {Random? random}) {
    final rng = random ?? _random;
    final int size = config.gridSize;
    final int wordCount = config.wordCount;

    // Boş ızgara
    List<List<String?>> grid = List.generate(
      size,
      (_) => List.filled(size, null),
    );

    // Tüm kategorilerden kelimeleri topla ve karıştır
    List<MapEntry<String, String>> allWords = [];
    for (var entry in WordData.categories.entries) {
      for (var word in entry.value) {
        allWords.add(MapEntry(entry.key, word));
      }
    }
    allWords.shuffle(rng);

    // Kelimeleri uzunluğa göre sırala (uzun kelimeler önce - daha kolay yerleşir)
    allWords.sort((a, b) => b.value.length.compareTo(a.value.length));

    // Kelimeleri yerleştir
    List<PlacedWord> placedWords = [];
    for (var entry in allWords) {
      if (placedWords.length >= wordCount) break;

      // Kelime ızgaraya sığıyor mu kontrol et
      if (entry.value.length > size) continue;

      final result = _tryPlaceWord(grid, entry.value, size, rng);
      if (result != null) {
        placedWords.add(PlacedWord(
          word: entry.value,
          category: entry.key,
          positions: result,
        ));
      }
    }

    // Boş hücreleri rastgele Türkçe harflerle doldur
    List<List<String>> finalGrid = List.generate(size, (r) {
      return List.generate(size, (c) {
        return grid[r][c] ??
            WordData.turkishAlphabet[rng.nextInt(WordData.turkishAlphabet.length)];
      });
    });

    return GridResult(grid: finalGrid, placedWords: placedWords);
  }

  /// Bir kelimeyi ızgaraya yerleştirmeyi dener
  static List<CellPosition>? _tryPlaceWord(
    List<List<String?>> grid,
    String word,
    int size,
    Random rng,
  ) {
    // Yönleri karıştır
    final dirs = List<int>.generate(_directions.length, (i) => i);
    dirs.shuffle(rng);

    for (var dirIndex in dirs) {
      final dir = _directions[dirIndex];
      final dr = dir[0];
      final dc = dir[1];

      // Geçerli başlangıç pozisyonlarını hesapla
      final positions = _getValidStartPositions(word.length, size, dr, dc);
      positions.shuffle(rng);

      for (var pos in positions) {
        final cells = _checkPlacement(grid, word, pos.row, pos.col, dr, dc, size);
        if (cells != null) {
          // Kelimeyi yerleştir
          for (int i = 0; i < word.length; i++) {
            grid[pos.row + i * dr][pos.col + i * dc] = word[i];
          }
          return cells;
        }
      }
    }
    return null; // Yerleştirilemedi
  }

  /// Verilen yön için geçerli başlangıç noktalarını döndürür
  static List<CellPosition> _getValidStartPositions(
    int wordLen,
    int gridSize,
    int dr,
    int dc,
  ) {
    List<CellPosition> positions = [];
    for (int r = 0; r < gridSize; r++) {
      for (int c = 0; c < gridSize; c++) {
        final endR = r + (wordLen - 1) * dr;
        final endC = c + (wordLen - 1) * dc;
        if (endR >= 0 && endR < gridSize && endC >= 0 && endC < gridSize) {
          positions.add(CellPosition(r, c));
        }
      }
    }
    return positions;
  }

  /// Kelimenin belirtilen konuma yerleşip yerleşemeyeceğini kontrol eder
  static List<CellPosition>? _checkPlacement(
    List<List<String?>> grid,
    String word,
    int startRow,
    int startCol,
    int dr,
    int dc,
    int size,
  ) {
    List<CellPosition> cells = [];
    for (int i = 0; i < word.length; i++) {
      int r = startRow + i * dr;
      int c = startCol + i * dc;

      if (r < 0 || r >= size || c < 0 || c >= size) return null;

      final existing = grid[r][c];
      if (existing != null && existing != word[i]) return null;

      cells.add(CellPosition(r, c));
    }
    return cells;
  }
}
