import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../theme/app_theme.dart';

class RadarAnimation extends StatefulWidget {
  final int deviceCount;
  final bool isScanning;

  const RadarAnimation({
    super.key,
    required this.deviceCount,
    this.isScanning = false,
  });

  @override
  State<RadarAnimation> createState() => _RadarAnimationState();
}

class _RadarAnimationState extends State<RadarAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    if (widget.isScanning) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(RadarAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isScanning != oldWidget.isScanning) {
      if (widget.isScanning) {
        _controller.repeat();
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 200,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: RadarPainter(
              animation: _controller.value,
              deviceCount: widget.deviceCount,
            ),
          );
        },
      ),
    );
  }
}

class RadarPainter extends CustomPainter {
  final double animation;
  final int deviceCount;

  RadarPainter({required this.animation, required this.deviceCount});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;

    // Draw concentric circles
    final circlePaint = Paint()
      ..color = AppTheme.primaryColor.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (int i = 1; i <= 3; i++) {
      canvas.drawCircle(center, radius * i / 3, circlePaint);
    }

    // Draw sweep (radar line)
    final sweepPaint = Paint()
      ..shader = SweepGradient(
        colors: [
          AppTheme.primaryColor.withOpacity(0.0),
          AppTheme.primaryColor.withOpacity(0.5),
          AppTheme.primaryColor.withOpacity(0.8),
        ],
        stops: const [0.0, 0.5, 1.0],
        transform: GradientRotation(animation * 2 * math.pi),
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, sweepPaint);

    // Draw center dot
    final centerPaint = Paint()
      ..color = AppTheme.primaryColor
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, 5, centerPaint);

    // Draw device dots
    final devicePaint = Paint()
      ..color = AppTheme.accentColor
      ..style = PaintingStyle.fill;

    final random = math.Random(42); // Fixed seed for consistent positions
    for (int i = 0; i < deviceCount; i++) {
      final angle = random.nextDouble() * 2 * math.pi;
      final distance = radius * 0.3 + random.nextDouble() * radius * 0.6;
      final x = center.dx + distance * math.cos(angle);
      final y = center.dy + distance * math.sin(angle);

      canvas.drawCircle(Offset(x, y), 4, devicePaint);

      // Draw pulse effect
      final pulsePaint = Paint()
        ..color = AppTheme.accentColor.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      final pulseRadius = 4 + (animation * 10) % 10;
      canvas.drawCircle(Offset(x, y), pulseRadius, pulsePaint);
    }
  }

  @override
  bool shouldRepaint(RadarPainter oldDelegate) {
    return animation != oldDelegate.animation ||
        deviceCount != oldDelegate.deviceCount;
  }
}
