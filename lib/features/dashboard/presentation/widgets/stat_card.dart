import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:rekognita_app/core/constants/app_colors.dart';
import 'package:rekognita_app/features/dashboard/domain/entities/dashboard_models.dart';

class StatCard extends StatelessWidget {
  const StatCard({required this.stat, required this.index, super.key});

  final DashboardStat stat;
  final int index;

  static const _icons = [
    Icons.description_rounded,
    Icons.people_rounded,
    Icons.category_rounded,
    Icons.verified_rounded,
  ];

  static const _colors = [
    Color(0xFF2563EB), // blue    — docs
    Color(0xFF059669), // emerald — people
    Color(0xFF7C3AED), // violet  — types
    Color(0xFF0891B2), // cyan    — accuracy
  ];

  // Mini sparkline data per metric
  static const _sparkData = [
    <double>[38, 52, 44, 68, 60, 78, 72, 88, 82, 98, 90, 108],
    <double>[18, 20, 22, 19, 23, 21, 23, 24, 22, 23, 24, 23],
    <double>[4, 4, 5, 4, 5, 5, 5, 6, 5, 5, 5, 5],
    <double>[97, 99, 98, 99, 99, 100, 99, 99, 100, 99, 100, 99],
  ];

  @override
  Widget build(BuildContext context) {
    final color = _colors[index % _colors.length];
    final icon = _icons[index % _icons.length];
    final sparkData = _sparkData[index % _sparkData.length];
    final delta = stat.delta;
    // Darker green for the sparkline line to stand out against the light strip bg
    const sparkGreen = Color(0xFF047857);
    final stripColor = delta != null ? sparkGreen : color;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2EAF4)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Stack(
        children: [
          // ── Radial glow in top-right corner (JSX element)
          Positioned(
            top: -28,
            right: -28,
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [color.withValues(alpha: 0.12), Colors.transparent],
                  stops: const [0.0, 1.0],
                ),
              ),
            ),
          ),

          // ── Full-height card layout
          Positioned.fill(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Top content: icon + label + number
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Row 1: Icon + Label
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                // JSX: accent + "12" (hex opacity 0x12 = 7%)
                                color: color.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(icon, size: 16, color: color),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                stat.label.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF0F172A),
                                  letterSpacing: 0.8,
                                  height: 1.2,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),

                        const Spacer(),

                        // Row 2: Dominant number (JSX: 72px Georgia w900)
                        Text(
                          stat.value,
                          style: const TextStyle(
                            fontSize: 44,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF0F172A),
                            letterSpacing: -3.0,
                            height: 1.0,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const Spacer(),
                      ],
                    ),
                  ),
                ),

                // ── Bottom strip (JSX: "ROW 3 — delta strip")
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        stripColor.withValues(alpha: 0.09),
                        stripColor.withValues(alpha: 0.04),
                      ],
                    ),
                    border: Border(
                      top: BorderSide(
                        color: stripColor.withValues(alpha: 0.18),
                      ),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Delta indicator (only when present) or trend label
                      if (delta != null) ...[
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: sparkGreen.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: const Icon(
                            Icons.trending_up_rounded,
                            size: 14,
                            color: Color(0xFF047857),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          delta,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF047857),
                            letterSpacing: -0.3,
                          ),
                        ),
                      ] else ...[
                        Icon(
                          Icons.show_chart_rounded,
                          size: 13,
                          color: color.withValues(alpha: 0.45),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Тренд',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: color.withValues(alpha: 0.45),
                          ),
                        ),
                      ],

                      const Spacer(),

                      // Sparkline (JSX: <Sparkline data={...} color={color}/>)
                      SizedBox(
                        width: 60,
                        height: 26,
                        child: CustomPaint(
                          painter: _SparklinePainter(
                            data: sparkData,
                            color: stripColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Draws a mini sparkline: gradient area fill + line + end dot
class _SparklinePainter extends CustomPainter {
  const _SparklinePainter({required this.data, required this.color});

  final List<double> data;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 2) return;

    final maxVal = data.reduce(math.max);
    final minVal = data.reduce(math.min);
    final range = (maxVal - minVal) < 0.001 ? 1.0 : maxVal - minVal;

    final pts = List<Offset>.generate(
      data.length,
      (i) => Offset(
        i / (data.length - 1) * size.width,
        size.height - ((data[i] - minVal) / range) * (size.height - 5) - 2,
      ),
    );

    // Gradient area fill
    final areaPath = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (int i = 1; i < pts.length; i++) {
      areaPath.lineTo(pts[i].dx, pts[i].dy);
    }
    areaPath
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(
      areaPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            color.withValues(alpha: 0.28),
            color.withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    // Line
    final linePath = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (int i = 1; i < pts.length; i++) {
      linePath.lineTo(pts[i].dx, pts[i].dy);
    }
    canvas.drawPath(
      linePath,
      Paint()
        ..color = color
        ..strokeWidth = 1.8
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // End dot: white fill + colored stroke
    final last = pts.last;
    canvas.drawCircle(last, 3.0, Paint()..color = Colors.white);
    canvas.drawCircle(
      last,
      3.0,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8,
    );
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter old) => false;
}
