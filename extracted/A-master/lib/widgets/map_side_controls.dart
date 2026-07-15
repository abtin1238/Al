import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// ستون دکمه‌های شناور سمت راست نقشه: قطب‌نما، موقعیت من، جهت‌یابی مسیر.
class MapSideControls extends StatelessWidget {
  final VoidCallback? onCompassTap;
  final VoidCallback? onLocationTap;
  final VoidCallback? onNavigateTap;

  const MapSideControls({
    super.key,
    this.onCompassTap,
    this.onLocationTap,
    this.onNavigateTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SideButton(
          onTap: onCompassTap,
          child: const _CompassIcon(),
        ),
        const SizedBox(height: 14),
        _SideButton(
          onTap: onLocationTap,
          child: const Icon(Icons.my_location_rounded,
              color: Colors.white, size: 22),
        ),
        const SizedBox(height: 14),
        _SideButton(
          onTap: onNavigateTap,
          child: const Icon(Icons.navigation_rounded,
              color: Colors.white, size: 22),
        ),
      ],
    );
  }
}

class _SideButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  const _SideButton({required this.child, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(26),
        child: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.fabBackground.withOpacity(0.92),
            border: Border.all(color: AppColors.fabBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.35),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: child,
        ),
      ),
    );
  }
}

class _CompassIcon extends StatelessWidget {
  const _CompassIcon();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 26,
      height: 26,
      child: CustomPaint(painter: _CompassPainter()),
    );
  }
}

class _CompassPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    final northPaint = Paint()..color = AppColors.signRed;
    final southPaint = Paint()..color = Colors.white70;

    final northPath = Path()
      ..moveTo(center.dx, 0)
      ..lineTo(center.dx - 6, center.dy)
      ..lineTo(center.dx + 6, center.dy)
      ..close();
    canvas.drawPath(northPath, northPaint);

    final southPath = Path()
      ..moveTo(center.dx, size.height)
      ..lineTo(center.dx - 6, center.dy)
      ..lineTo(center.dx + 6, center.dy)
      ..close();
    canvas.drawPath(southPath, southPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
