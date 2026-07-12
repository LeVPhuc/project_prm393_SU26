import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class BrandLogo extends StatelessWidget {
  final double size;
  final bool showBackground;

  const BrandLogo({
    super.key,
    this.size = 100,
    this.showBackground = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = CustomPaint(
      size: Size(size, size),
      painter: _LogoPainter(),
    );

    if (showBackground) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F3EE), // Sage cream background matching logo border
          borderRadius: BorderRadius.circular(size * 0.28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: EdgeInsets.all(size * 0.06),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.primaryLight,
              width: size * 0.035,
            ),
          ),
          child: content,
        ),
      );
    }

    return content;
  }
}

class _LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Draw the green droplet (in the upper half)
    final dropPath = Path();
    final dropCenter = Offset(w * 0.5, h * 0.38);
    final dropWidth = w * 0.22;
    final dropHeight = h * 0.30;

    dropPath.moveTo(dropCenter.dx, dropCenter.dy - dropHeight * 0.5);
    dropPath.cubicTo(
      dropCenter.dx + dropWidth * 0.5, dropCenter.dy - dropHeight * 0.1,
      dropCenter.dx + dropWidth * 0.5, dropCenter.dy + dropHeight * 0.5,
      dropCenter.dx, dropCenter.dy + dropHeight * 0.5,
    );
    dropPath.cubicTo(
      dropCenter.dx - dropWidth * 0.5, dropCenter.dy + dropHeight * 0.5,
      dropCenter.dx - dropWidth * 0.5, dropCenter.dy - dropHeight * 0.1,
      dropCenter.dx, dropCenter.dy - dropHeight * 0.5,
    );
    dropPath.close();

    final dropPaint = Paint()
      ..color = const Color(0xFFA3C1AD) // Sage green/olive drop color
      ..style = PaintingStyle.fill;
    canvas.drawPath(dropPath, dropPaint);

    final dropStrokePaint = Paint()
      ..color = const Color(0xFF588157) // Darker sage green outline
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.035
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(dropPath, dropStrokePaint);

    // Draw the hand (below the droplet)
    final handPaint = Paint()
      ..color = const Color(0xFFE6C2A4) // Skin tone
      ..style = PaintingStyle.fill;

    final handOutlinePaint = Paint()
      ..color = const Color(0xFF8A6C58) // Hand outline
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.045
      ..strokeCap = StrokeCap.round;

    final handPath = Path();
    handPath.moveTo(w * 0.16, h * 0.65);
    handPath.quadraticBezierTo(w * 0.28, h * 0.81, w * 0.44, h * 0.81); // palm bottom
    handPath.quadraticBezierTo(w * 0.66, h * 0.81, w * 0.76, h * 0.64); // fingers curve up
    handPath.quadraticBezierTo(w * 0.80, h * 0.58, w * 0.72, h * 0.54); // fingers top back
    handPath.quadraticBezierTo(w * 0.62, h * 0.60, w * 0.50, h * 0.63); // inner palm curve
    handPath.quadraticBezierTo(w * 0.40, h * 0.64, w * 0.30, h * 0.56); // thumb
    handPath.quadraticBezierTo(w * 0.22, h * 0.50, w * 0.16, h * 0.57); // thumb back
    handPath.close();

    canvas.drawPath(handPath, handPaint);
    canvas.drawPath(handPath, handOutlinePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
