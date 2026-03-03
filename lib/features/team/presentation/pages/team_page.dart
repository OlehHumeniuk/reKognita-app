import 'package:flutter/material.dart';
import 'package:rekognita_app/core/data/mock_data.dart';
import 'package:rekognita_app/features/team/presentation/providers/team_controller.dart';
import 'package:rekognita_app/features/team/presentation/widgets/team_details_card.dart';
import 'package:rekognita_app/features/team/presentation/widgets/team_member_tile.dart';
import 'package:rekognita_app/shared/widgets/rk_card.dart';
import 'package:rekognita_app/shared/widgets/section_header.dart';

class TeamPage extends StatefulWidget {
  const TeamPage({super.key});

  @override
  State<TeamPage> createState() => _TeamPageState();
}

class _TeamPageState extends State<TeamPage> {
  late final TeamController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TeamController(seedEmployees: seedEmployees);
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
        return LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth > 1080;
            final list = _buildEmployeeList();
            final details = TeamDetailsCard(employee: _controller.selected);

            if (wide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 2, child: list),
                  const SizedBox(width: 16),
                  Expanded(child: details),
                ],
              );
            }

            return Column(
              children: [list, const SizedBox(height: 16), details],
            );
          },
        );
      },
    );
  }

  Widget _buildEmployeeList() {
    return Column(
      children: [
        const SectionHeader(
          title: 'Команда',
          subtitle: 'Керування доступами співробітників',
          buttonLabel: '+ Додати',
        ),
        const SizedBox(height: 12),
        RkCard(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: TextField(
            onChanged: _controller.setQuery,
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: 'Пошук співробітника...',
              icon: Icon(Icons.search_rounded, color: Color(0xFF64748B)),
            ),
          ),
        ),
        const SizedBox(height: 12),
        ..._controller.filteredEmployees.map((employee) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: TeamMemberTile(
              employee: employee,
              selected: _controller.selected?.id == employee.id,
              onTap: () => _controller.select(employee),
            ),
          );
        }),
      ],
    );
  }
}
