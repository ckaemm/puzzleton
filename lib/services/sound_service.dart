import 'dart:js_util' as js_util;
import 'dart:js' as js;

// ── Nota Modeli ──
class _Note {
  final double freq;
  final double duration;
  final double volume;
  final String waveType;

  const _Note(
    this.freq,
    this.duration, {
    this.volume = 0.12,
    this.waveType = 'sine',
  });
}

// ── Ses Servisi ──
class SoundService {
  static bool _enabled = true;

  static bool get enabled => _enabled;
  static void toggle() => _enabled = !_enabled;
  static void setEnabled(bool value) => _enabled = value;

  static void _playNotes(List<_Note> notes) {
    if (!_enabled) return;
    try {
      // new AudioContext()
      final ctxConstructor = js_util.getProperty(js.context, 'AudioContext');
      final ctx = js_util.callConstructor(ctxConstructor, []);
      double time = (js_util.getProperty(ctx, 'currentTime') as num).toDouble();
      final destination = js_util.getProperty(ctx, 'destination');

      for (final note in notes) {
        // createOscillator()
        final osc = js_util.callMethod(ctx, 'createOscillator', []);
        // createGain()
        final gainNode = js_util.callMethod(ctx, 'createGain', []);

        // osc.connect(gainNode)
        js_util.callMethod(osc, 'connect', [gainNode]);
        // gainNode.connect(destination)
        js_util.callMethod(gainNode, 'connect', [destination]);

        // osc.frequency.value = freq
        final freq = js_util.getProperty(osc, 'frequency');
        js_util.setProperty(freq, 'value', note.freq);

        // osc.type = waveType
        js_util.setProperty(osc, 'type', note.waveType);

        // gainNode.gain.value = volume
        final gain = js_util.getProperty(gainNode, 'gain');
        js_util.setProperty(gain, 'value', note.volume);

        // osc.start(time)
        js_util.callMethod(osc, 'start', [time]);
        time += note.duration;
        // osc.stop(time)
        js_util.callMethod(osc, 'stop', [time]);
      }
    } catch (_) {
      // Web Audio desteklenmiyorsa sessizce devam et
    }
  }

  /// Kelime bulunduğunda
  static void playWordFound() {
    _playNotes([
      _Note(523.25, 0.08, volume: 0.10),
      _Note(659.25, 0.08, volume: 0.12),
      _Note(783.99, 0.12, volume: 0.14),
      _Note(1046.50, 0.18, volume: 0.10),
    ]);
  }

  /// Yanlış seçim
  static void playWrongSelection() {
    _playNotes([
      _Note(250.0, 0.12, volume: 0.08, waveType: 'triangle'),
      _Note(200.0, 0.15, volume: 0.06, waveType: 'triangle'),
    ]);
  }

  /// İpucu kullanıldığında
  static void playHint() {
    _playNotes([
      _Note(880.0, 0.08, volume: 0.10),
      _Note(0.01, 0.04, volume: 0.0),
      _Note(880.0, 0.12, volume: 0.10),
    ]);
  }

  /// Oyun kazanıldı
  static void playGameWon() {
    _playNotes([
      _Note(523.25, 0.12, volume: 0.10),
      _Note(587.33, 0.12, volume: 0.10),
      _Note(659.25, 0.12, volume: 0.12),
      _Note(783.99, 0.15, volume: 0.12),
      _Note(0.01, 0.05, volume: 0.0),
      _Note(783.99, 0.10, volume: 0.10),
      _Note(1046.50, 0.25, volume: 0.14),
    ]);
  }

  /// Süre doldu
  static void playGameLost() {
    _playNotes([
      _Note(493.88, 0.20, volume: 0.10, waveType: 'triangle'),
      _Note(440.00, 0.20, volume: 0.10, waveType: 'triangle'),
      _Note(392.00, 0.20, volume: 0.08, waveType: 'triangle'),
      _Note(349.23, 0.35, volume: 0.06, waveType: 'triangle'),
    ]);
  }

  /// Son 10 saniye tick
  static void playTick() {
    _playNotes([
      _Note(1200.0, 0.03, volume: 0.06, waveType: 'square'),
    ]);
  }

  /// Sürükleme başlangıcı
  static void playSelect() {
    _playNotes([
      _Note(600.0, 0.04, volume: 0.05),
    ]);
  }
}
