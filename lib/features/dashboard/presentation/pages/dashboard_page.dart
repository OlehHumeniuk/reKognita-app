import 'package:flutter/material.dart';
import 'package:rekognita_app/core/data/mock_data.dart';
import 'package:rekognita_app/features/company_context/domain/entities/company.dart';
import 'package:rekognita_app/features/dashboard/presentation/widgets/activity_panel.dart';
import 'package:rekognita_app/features/dashboard/presentation/widgets/distribution_panel.dart';
import 'package:rekognita_app/features/dashboard/presentation/widgets/stat_card.dart';
import 'package:rekognita_app/features/dashboard/presentation/widgets/usage_banner.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({required this.company, super.key});

  final Company company;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Добрий день, Андрію',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
            letterSpacing: -0.8,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Ось що відбувається у компанії сьогодні',
          style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
        ),
        const SizedBox(height: 20),
        UsageBanner(company: company),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final columns = width > 1000
                ? 4
                : width > 650
                ? 2
                : 1;
            return GridView.count(
              crossAxisCount: columns,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.7,
              children: seedStats
                  .map((stat) => StatCard(stat: stat))
                  .toList(growable: false),
            );
          },
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth > 980;
            if (wide) {
              return const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: ActivityPanel(items: seedActivity)),
                  SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: DistributionPanel(items: seedDistribution),
                  ),
                ],
              );
            }
            return const Column(
              children: [
                ActivityPanel(items: seedActivity),
                SizedBox(height: 16),
                DistributionPanel(items: seedDistribution),
              ],
            );
          },
        ),
      ],
    );
  }
}
