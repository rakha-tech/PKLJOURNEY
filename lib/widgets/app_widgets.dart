import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class BrandMark extends StatelessWidget {
  const BrandMark({
    super.key,
    this.compact = false,
    this.light = false,
    this.showWordmark = true,
  });

  final bool compact;
  final bool light;
  final bool showWordmark;

  @override
  Widget build(BuildContext context) {
    final color = light ? AppColors.cream : AppColors.maroon;
    final markSize = compact ? 42.0 : 82.0;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: markSize,
          height: markSize,
          child: CustomPaint(painter: _BrandMarkPainter(color)),
        ),
        if (showWordmark) ...[
          SizedBox(width: compact ? 9 : 13),
          Text(
            'PKLJOURNEY',
            style: TextStyle(
              color: color,
              fontSize: compact ? 15 : 19,
              fontWeight: FontWeight.w800,
              letterSpacing: compact ? 1.35 : 2.2,
            ),
          ),
        ],
      ],
    );
  }
}

class _BrandMarkPainter extends CustomPainter {
  _BrandMarkPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 100;
    canvas.save();
    canvas.scale(scale);
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final fill = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Sun rays and open book sit above the shield, echoing the supplied mark.
    for (var i = 0; i < 7; i++) {
      final x = 29.0 + (i * 7.0);
      final top = i == 3 ? 2.0 : (i == 2 || i == 4 ? 6.0 : 11.0);
      canvas.drawLine(Offset(x, top), Offset(x, top + 6), stroke);
    }
    canvas.drawArc(
      const Rect.fromLTWH(31, 13, 38, 29),
      3.14,
      3.14,
      false,
      stroke,
    );
    final shield = Path()
      ..moveTo(17, 28)
      ..lineTo(50, 35)
      ..lineTo(83, 28)
      ..lineTo(80, 66)
      ..quadraticBezierTo(77, 83, 50, 96)
      ..quadraticBezierTo(23, 83, 20, 66)
      ..close();
    canvas.drawPath(shield, stroke);

    final book = Path()
      ..moveTo(29, 43)
      ..quadraticBezierTo(39, 39, 49, 47)
      ..lineTo(49, 63)
      ..quadraticBezierTo(39, 56, 29, 60)
      ..close()
      ..moveTo(51, 47)
      ..quadraticBezierTo(62, 39, 72, 43)
      ..lineTo(72, 60)
      ..quadraticBezierTo(61, 56, 51, 63)
      ..close();
    canvas.drawPath(book, stroke);
    final growth = Path()
      ..moveTo(28, 75)
      ..lineTo(48, 65)
      ..lineTo(60, 52)
      ..lineTo(68, 56)
      ..lineTo(79, 38);
    canvas.drawPath(growth, stroke);
    final arrow = Path()
      ..moveTo(68, 38)
      ..lineTo(80, 35)
      ..lineTo(79, 48)
      ..close();
    canvas.drawPath(arrow, fill);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _BrandMarkPainter oldDelegate) =>
      oldDelegate.color != color;
}

class PageHeading extends StatelessWidget {
  const PageHeading({
    super.key,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 4),
                Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key, this.action, this.onAction});

  final String text;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.titleLarge),
          ),
          if (action != null)
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.maroon,
                padding: EdgeInsets.zero,
              ),
              child: Text(action!),
            ),
        ],
      ),
    );
  }
}

class InfoPill extends StatelessWidget {
  const InfoPill({
    super.key,
    required this.label,
    this.color = AppColors.paleGreen,
    this.textColor = AppColors.green,
    this.icon,
  });

  final String label;
  final Color color;
  final Color textColor;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.circular(30)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: textColor),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class WhiteCard extends StatelessWidget {
  const WhiteCard({super.key, required this.child, this.padding = 16});

  final Widget child;
  final double padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.line),
      ),
      child: child,
    );
  }
}

String currentDateLabel() {
  const days = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu'
  ];
  const months = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember'
  ];
  final now = DateTime.now();
  return '${days[now.weekday - 1]}, ${now.day} ${months[now.month - 1]} ${now.year}';
}

String currentTimeLabel() {
  final now = DateTime.now();
  return '${now.hour.toString().padLeft(2, '0')}.${now.minute.toString().padLeft(2, '0')}';
}