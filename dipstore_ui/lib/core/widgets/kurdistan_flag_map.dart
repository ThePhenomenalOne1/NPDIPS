import 'package:dipstore_ui/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class KurdistanFlagMap extends StatelessWidget {
  final double size;
  final double glow;

  const KurdistanFlagMap({
    super.key,
    this.size = 140,
    this.glow = 0.28,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _KurdistanFlagMapPainter(glow: glow),
      ),
    );
  }
}

class _KurdistanFlagMapPainter extends CustomPainter {
  final double glow;

  _KurdistanFlagMapPainter({required this.glow});

  @override
  void paint(Canvas canvas, Size size) {
    final mapPath = Path()
      ..moveTo(size.width * 0.12, size.height * 0.46)
      ..lineTo(size.width * 0.22, size.height * 0.34)
      ..lineTo(size.width * 0.30, size.height * 0.18)
      ..lineTo(size.width * 0.48, size.height * 0.14)
      ..lineTo(size.width * 0.64, size.height * 0.18)
      ..lineTo(size.width * 0.74, size.height * 0.32)
      ..lineTo(size.width * 0.88, size.height * 0.40)
      ..lineTo(size.width * 0.78, size.height * 0.55)
      ..lineTo(size.width * 0.78, size.height * 0.67)
      ..lineTo(size.width * 0.84, size.height * 0.82)
      ..lineTo(size.width * 0.70, size.height * 0.86)
      ..lineTo(size.width * 0.56, size.height * 0.80)
      ..lineTo(size.width * 0.52, size.height * 0.70)
      ..lineTo(size.width * 0.42, size.height * 0.58)
      ..lineTo(size.width * 0.30, size.height * 0.58)
      ..lineTo(size.width * 0.22, size.height * 0.58)
      ..lineTo(size.width * 0.16, size.height * 0.54)
      ..close();

    final glowPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: glow)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawPath(mapPath.shift(const Offset(0, 3)), glowPaint);

    final redStripe = Paint()
      ..color = const Color(0xFFD63E3A)
      ..style = PaintingStyle.fill;
    final whiteStripe = Paint()
      ..color = const Color(0xFFEFEFEF)
      ..style = PaintingStyle.fill;
    final greenStripe = Paint()
      ..color = const Color(0xFF2E8E4A)
      ..style = PaintingStyle.fill;

    canvas.save();
    canvas.clipPath(mapPath);
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height * 0.33),
      redStripe,
    );
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.33, size.width, size.height * 0.34),
      whiteStripe,
    );
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.67, size.width, size.height * 0.33),
      greenStripe,
    );

    final sunPaint = Paint()
      ..shader = const RadialGradient(
        colors: [
          Color(0xFFFFE98A),
          Color(0xFFF7C948),
          Color(0xFFE8A91C),
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(size.width * 0.53, size.height * 0.48),
          radius: size.width * 0.12,
        ),
      );
    canvas.drawCircle(
      Offset(size.width * 0.53, size.height * 0.48),
      size.width * 0.12,
      sunPaint,
    );
    canvas.restore();

    final edgeRed = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..color = const Color(0xFFEC6D81).withValues(alpha: 0.95);
    final edgeGold = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..color = const Color(0xFFF8DF7D).withValues(alpha: 0.95);
    final edgeMint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = const Color(0xFFBDF7D8).withValues(alpha: 0.95);

    canvas.drawPath(mapPath.shift(const Offset(1.4, 1.8)), edgeRed);
    canvas.drawPath(mapPath.shift(const Offset(0.6, 0.8)), edgeGold);
    canvas.drawPath(mapPath, edgeMint);
  }

  @override
  bool shouldRepaint(covariant _KurdistanFlagMapPainter oldDelegate) {
    return oldDelegate.glow != glow;
  }
}
