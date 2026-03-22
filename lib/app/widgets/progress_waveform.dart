import 'dart:math' as math;

import 'package:flutter/material.dart';

class ProgressWaveform extends StatelessWidget {
  const ProgressWaveform({
    super.key,
    required this.seed,
    required this.progress,
    required this.onSeekRatio,
    this.barCount = 64,
    this.height = 64,
  });

  final String seed;
  final double progress;
  final ValueChanged<double> onSeekRatio;
  final int barCount;
  final double height;

  static final Map<String, List<double>> _cache = <String, List<double>>{};

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bars = _cache.putIfAbsent(seed, () => _generateBars(seed, barCount));

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (details) {
        final box = context.findRenderObject() as RenderBox?;
        if (box == null || box.size.width <= 0) return;
        final ratio = (details.localPosition.dx / box.size.width).clamp(
          0.0,
          1.0,
        );
        onSeekRatio(ratio);
      },
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: CustomPaint(
          painter: _WaveformPainter(
            bars: bars,
            progress: progress.clamp(0.0, 1.0),
            playedColor: theme.colorScheme.primary,
            unplayedColor: theme.colorScheme.outlineVariant,
          ),
        ),
      ),
    );
  }

  List<double> _generateBars(String seed, int count) {
    var value = 0;
    for (final code in seed.codeUnits) {
      value = ((value * 131) + code) & 0x7fffffff;
    }
    if (value == 0) value = 1979;

    final bars = <double>[];
    for (var i = 0; i < count; i++) {
      value = ((value * 1103515245) + 12345) & 0x7fffffff;
      final normalized = (value % 1000) / 1000.0;
      final wave = (math.sin(i / 5.5) + 1) / 2;
      final amp = (0.35 * normalized) + (0.65 * wave);
      bars.add(amp.clamp(0.15, 1.0));
    }
    return bars;
  }
}

class _WaveformPainter extends CustomPainter {
  _WaveformPainter({
    required this.bars,
    required this.progress,
    required this.playedColor,
    required this.unplayedColor,
  });

  final List<double> bars;
  final double progress;
  final Color playedColor;
  final Color unplayedColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (bars.isEmpty) return;

    final barWidth = size.width / ((bars.length * 1.8) - 0.8);
    final gap = barWidth * 0.8;
    final playedThreshold = size.width * progress;
    final radius = Radius.circular(barWidth * 0.45);

    var x = 0.0;
    for (var i = 0; i < bars.length; i++) {
      final amp = bars[i];
      final h = (size.height * amp).clamp(size.height * 0.18, size.height);
      final top = (size.height - h) / 2;
      final rect = Rect.fromLTWH(x, top, barWidth, h);
      final isPlayed = (x + barWidth) <= playedThreshold;

      final paint = Paint()
        ..color = isPlayed
            ? playedColor
            : unplayedColor.withOpacity(0.65);
      canvas.drawRRect(RRect.fromRectAndRadius(rect, radius), paint);
      x += barWidth + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _WaveformPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.playedColor != playedColor ||
        oldDelegate.unplayedColor != unplayedColor ||
        oldDelegate.bars != bars;
  }
}
