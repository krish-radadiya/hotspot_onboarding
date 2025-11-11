import 'dart:math'; // 👈 needed for sin() and pi
import 'package:flutter/material.dart';

/// Wavy progress bar — draws a smooth wave that fills as [progress] increases.
class WavyProgressPainter extends CustomPainter {
  final double progress;

  WavyProgressPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    // Wave parameters — tweak for different looks
    const double waveHeight = 2.0; // amplitude
    const double waveLength = 14.0; // wavelength
    const double strokeWidth = 1.5;

    // Background wave (gray)
    final Paint backgroundPaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Progress wave (gradient blue)
    final Paint progressPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF8B9BFF), Color(0xFF586BFF)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Create two paths: one for full wave, one for progress fill
    final Path backgroundPath = Path();
    final Path progressPath = Path();

    // Generate sine wave points
    for (double x = 0; x <= size.width; x++) {
      final double y = size.height / 2 + waveHeight * sin((2 * pi / waveLength) * x);
      if (x == 0) {
        backgroundPath.moveTo(x, y);
        progressPath.moveTo(x, y);
      } else {
        backgroundPath.lineTo(x, y);
        if (x <= size.width * progress) {
          progressPath.lineTo(x, y);
        }
      }
    }

    // Draw both paths
    canvas.drawPath(backgroundPath, backgroundPaint);
    canvas.drawPath(progressPath, progressPaint);
  }

  @override
  bool shouldRepaint(covariant WavyProgressPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
