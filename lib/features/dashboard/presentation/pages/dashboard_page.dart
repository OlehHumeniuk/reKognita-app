import 'package:flutter/material.dart';
import 'package:rekognita_app/features/company_context/domain/entities/company.dart';
import 'package:rekognita_app/features/dashboard/presentation/providers/dashboard_controller.dart';
import 'package:rekognita_app/features/dashboard/presentation/widgets/activity_panel.dart';
import 'package:rekognita_app/features/dashboard/presentation/widgets/distribution_panel.dart';
import 'package:rekognita_app/features/dashboard/presentation/widgets/doc_process_panel.dart';
import 'package:rekognita_app/features/dashboard/presentation/widgets/stat_card.dart';
import 'package:rekognita_app/features/dashboard/presentation/widgets/usage_banner.dart';

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
      _controller.load(widget.accessToken);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        if (_controller.isLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 80),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (_controller.error != null && _controller.stats.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 80),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.cloud_off_rounded, size: 40, color: Color(0xFF94A3B8)),
                  const SizedBox(height: 12),
                  Text(
                    _controller.error!,
                    style: const TextStyle(color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => _controller.load(widget.accessToken),
                    child: const Text('Повторити'),
                  ),
                ],
              ),
            ),
          );
        }

        final displayCompany = _controller.company ?? widget.company;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Дашборд',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
                letterSpacing: -0.8,
              ),
            ),
            const SizedBox(height: 3),
            const Text(
              'Ось що відбувається у компанії сьогодні',
              style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
            ),
            const SizedBox(height: 16),

            UsageBanner(
              company: displayCompany,
              onUpgrade: widget.onNavigateToBilling,
            ),
            const SizedBox(height: 16),

            if (_controller.stats.isNotEmpty)
              SizedBox(
                height: 188,
                child: StatCard(stat: _controller.stats.first, index: 0),
              ),
            const SizedBox(height: 20),

            if (_controller.docRecords.isNotEmpty)
              DocProcessPanel(records: _controller.docRecords),
            const SizedBox(height: 20),

            LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth > 980;
                if (wide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: ActivityPanel(items: _controller.activity),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: DistributionPanel(items: _controller.distribution),
                      ),
                    ],
                  );
                }
                return Column(
                  children: [
                    ActivityPanel(items: _controller.activity),
                    const SizedBox(height: 16),
                    DistributionPanel(items: _controller.distribution),
                  ],
                );
              },
            ),
          ],
        );
      },
    );
  }
}
