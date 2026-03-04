import 'package:flutter/material.dart';
import 'package:rekognita_app/core/constants/app_colors.dart';
import 'package:rekognita_app/features/company_context/domain/entities/company.dart';
import 'package:rekognita_app/features/dashboard/presentation/providers/dashboard_controller.dart';
import 'package:rekognita_app/features/dashboard/presentation/widgets/distribution_panel.dart';
import 'package:rekognita_app/features/dashboard/presentation/widgets/doc_process_panel.dart';
import 'package:rekognita_app/features/dashboard/presentation/widgets/stat_card.dart';
import 'package:rekognita_app/features/dashboard/presentation/widgets/usage_banner.dart';

// ── Period options ────────────────────────────────────────────────────────────

const _kPeriods = [
  ('today', 'Сьогодні'),
  ('week', 'Тиждень'),
  ('month', 'Місяць'),
  ('year', 'Рік'),
  ('all', 'Весь час'),
];

// ── Page ──────────────────────────────────────────────────────────────────────

class DashboardPage extends StatefulWidget {
  const DashboardPage({
    required this.accessToken,
    required this.company,
    required this.onNavigateToBilling,
    super.key,
  });

  final String accessToken;
  final Company company;
  final VoidCallback onNavigateToBilling;

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late final DashboardController _controller;

  @override
  void initState() {
    super.initState();
    _controller = DashboardController();
    _controller.load(widget.accessToken);
  }

  @override
  void didUpdateWidget(DashboardPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.accessToken != widget.accessToken) {
      _controller.load(widget.accessToken, period: _controller.period);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _selectPeriod(String period) {
    if (_controller.period == period) return;
    _controller.load(widget.accessToken, period: period);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final isLoading = _controller.isLoading;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Period selector ──────────────────────────────────────────────
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final (value, label) in _kPeriods) ...[
                    _PeriodChip(
                      label: label,
                      isActive: _controller.period == value,
                      onTap: () => _selectPeriod(value),
                    ),
                    const SizedBox(width: 6),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 14),

            // ── Error state (show chips + error, allow retry) ────────────────
            if (_controller.error != null && _controller.stats.isEmpty) ...[
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 60),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.cloud_off_rounded,
                        size: 40,
                        color: Color(0xFF94A3B8),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _controller.error!,
                        style: const TextStyle(color: Color(0xFF64748B)),
                      ),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: () => _controller.load(
                          widget.accessToken,
                          period: _controller.period,
                        ),
                        child: const Text('Повторити'),
                      ),
                    ],
                  ),
                ),
              ),
            ] else if (isLoading) ...[
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 80),
                  child: CircularProgressIndicator(),
                ),
              ),
            ] else ...[
              // ── Content ───────────────────────────────────────────────────
              UsageBanner(
                company: _controller.company ?? widget.company,
                onUpgrade: widget.onNavigateToBilling,
              ),
              const SizedBox(height: 16),

              if (_controller.stats.isNotEmpty)
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: StatCard(
                          stat: _controller.stats.first,
                          index: 0,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _SavedHoursCard(
                          hours: _controller.savedHours,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 20),

              if (_controller.docRecords.isNotEmpty)
                DocProcessPanel(records: _controller.docRecords),
              const SizedBox(height: 20),

              if (_controller.distribution.isNotEmpty)
                DistributionPanel(
                  items: _controller.distribution,
                  period: _controller.period,
                ),
            ],
          ],
        );
      },
    );
  }
}

// ── Saved hours card ─────────────────────────────────────────────────────────

class _SavedHoursCard extends StatelessWidget {
  const _SavedHoursCard({required this.hours});

  final int hours;

  static const _color = Color(0xFF059669);
  static const _bgColor = Color(0xFFF0FDF4);
  static const _borderColor = Color(0xFFBBF7D0);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _borderColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: _borderColor.withValues(alpha: 0.5),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Icon — top-right corner
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: 30,
              height: 30,
              decoration: const BoxDecoration(
                color: _bgColor,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(19),
                  bottomLeft: Radius.circular(9),
                ),
              ),
              child: const Icon(
                Icons.hourglass_top_rounded,
                size: 17,
                color: _color,
              ),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'ЛЮДИНО-ГОДИН',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                    letterSpacing: 0.3,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                Text(
                  '$hours',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 56,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A),
                    letterSpacing: -3.0,
                    height: 1.0,
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

// ── Period chip ───────────────────────────────────────────────────────────────

class _PeriodChip extends StatelessWidget {
  const _PeriodChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isActive ? AppColors.brand : AppColors.bg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? AppColors.brand : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isActive ? Colors.white : AppColors.muted,
          ),
        ),
      ),
    );
  }
}
