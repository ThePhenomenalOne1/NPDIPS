import 'package:dipstore_ui/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class KrdLogo extends StatelessWidget {
  final double size;
  final Color? color;

  const KrdLogo({super.key, this.size = 100, this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _LogoPainter(color: color)),
    );
  }
}

class _LogoPainter extends CustomPainter {
  final Color? color;

  _LogoPainter({this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w * 0.5, h * 0.5);

    final outerGlowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.accent.withValues(alpha: 0.34),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: w * 0.55));
    canvas.drawCircle(center, w * 0.55, outerGlowPaint);

    final topPath = Path()
      ..moveTo(w * 0.12, h * 0.28)
      ..lineTo(w * 0.58, h * 0.12)
      ..lineTo(w * 0.90, h * 0.35)
      ..lineTo(w * 0.48, h * 0.48)
      ..lineTo(w * 0.36, h * 0.62)
      ..lineTo(w * 0.12, h * 0.28)
      ..close();

    final bottomPath = Path()
      ..moveTo(w * 0.88, h * 0.72)
      ..lineTo(w * 0.42, h * 0.88)
      ..lineTo(w * 0.10, h * 0.65)
      ..lineTo(w * 0.52, h * 0.52)
      ..lineTo(w * 0.64, h * 0.38)
      ..lineTo(w * 0.88, h * 0.72)
      ..close();

    final basePaint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    if (color != null) {
      basePaint.color = color!;
    } else {
      basePaint.shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFF8ECD0),
          Color(0xFFD6B56E),
          AppColors.kGold,
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    }

    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.18)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawPath(topPath.shift(const Offset(0, 3)), shadowPaint);
    canvas.drawPath(bottomPath.shift(const Offset(0, 3)), shadowPaint);

    canvas.drawPath(topPath, basePaint);
    canvas.drawPath(bottomPath, basePaint);

    final highlightPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withValues(alpha: 0.5),
          Colors.white.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h * 0.6))
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.018
      ..isAntiAlias = true;

    final edgePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.010
      ..isAntiAlias = true;

    canvas.drawPath(topPath, edgePaint);
    canvas.drawPath(bottomPath, edgePaint);
    canvas.drawPath(topPath, highlightPaint);
  }

  @override
  bool shouldRepaint(covariant _LogoPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
