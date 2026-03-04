import 'package:core_ui/core_ui.dart' hide AppColors;
import 'package:flutter/material.dart';
import 'package:rekognita_app/core/constants/app_colors.dart';
import 'package:rekognita_app/features/team/domain/entities/employee.dart';
import 'package:rekognita_app/features/team/presentation/providers/team_controller.dart';
import 'package:rekognita_app/features/team/presentation/widgets/team_details_card.dart';
import 'package:rekognita_app/features/team/presentation/widgets/team_member_tile.dart';
import 'package:rekognita_app/shared/widgets/rk_card.dart';
import 'package:rekognita_app/shared/widgets/section_header.dart';

class TeamPage extends StatefulWidget {
  const TeamPage({
    required this.accessToken,
    super.key,
  });

  final String accessToken;

  @override
  State<TeamPage> createState() => _TeamPageState();
}

class _TeamPageState extends State<TeamPage> {
  late final TeamController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TeamController(accessToken: widget.accessToken);
    _controller.load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _showCreateDialog() async {
    final result = await _showEmployeeFormDialog(context);
    if (result != null) {
      await _controller.createEmployee(
        name: result['name']!,
        role: result['role']!,
        dept: result['dept']!,
      );
    }
  }

  Future<void> _showEditDialog(Employee employee) async {
    final result = await _showEmployeeFormDialog(
      context,
      initialName: employee.name,
      initialRole: employee.role,
      initialDept: employee.dept,
    );
    if (result != null) {
      await _controller.updateEmployee(
        id: employee.id,
        name: result['name']!,
        role: result['role']!,
        dept: result['dept']!,
      );
    }
  }

  Future<void> _showAddDocDialog(Employee employee) async {
    final docType = await CustomInputDialog.showTextInput(
      context: context,
      title: 'Додати тип документа',
      subtitle: 'Введіть назву типу документа для ${employee.name}',
      cancelButtonText: 'Скасувати',
      actionButtonText: 'Додати',
      hintText: 'напр. Накладні, Договори...',
      actionButtonColor: AppColors.brand,
      actionButtonHoverColor: AppColors.brandLight,
      actionButtonSplashColor: AppColors.brandLight,
      actionButtonTextColor: AppColors.white,
    );
    if (docType != null && docType.isNotEmpty) {
      await _controller.addDoc(employee.id, docType);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        if (_controller.isLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 64),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (_controller.error != null && _controller.filteredEmployees.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 64),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.cloud_off_rounded,
                      size: 40, color: AppColors.muted),
                  const SizedBox(height: 12),
                  Text(
                    _controller.error!,
                    style: const TextStyle(color: AppColors.muted),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: _controller.load,
                    style: FilledButton.styleFrom(
                        backgroundColor: AppColors.brand),
                    child: const Text('Повторити'),
                  ),
                ],
              ),
            ),
          );
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth > 1080;
            final list = _buildEmployeeList();
            final selected = _controller.selected;
            final details = TeamDetailsCard(
              employee: selected,
              isSaving: _controller.isSaving,
              onEdit: selected != null ? () => _showEditDialog(selected) : null,
              onToggleStatus: selected != null
                  ? () => _controller.toggleStatus(selected.id)
                  : null,
              onAddDoc: selected != null ? () => _showAddDocDialog(selected) : null,
              onRemoveDoc: selected != null
                  ? (doc) => _controller.removeDoc(selected.id, doc)
                  : null,
            );

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
        SectionHeader(
          title: 'Команда',
          subtitle: 'Керування доступами співробітників',
          buttonLabel: '+ Додати',
          onTap: _showCreateDialog,
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

Future<Map<String, String>?> _showEmployeeFormDialog(
  BuildContext context, {
  String initialName = '',
  String initialRole = '',
  String initialDept = '',
}) async {
  final nameController = TextEditingController(text: initialName);
  final roleController = TextEditingController(text: initialRole);
  final deptController = TextEditingController(text: initialDept);

  final result = await showDialog<Map<String, String>>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(
        initialName.isEmpty ? 'Новий співробітник' : 'Редагувати співробітника',
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _FormField(controller: nameController, label: "Ім'я та прізвище", hint: 'Олексій Коваль'),
          const SizedBox(height: 12),
          _FormField(controller: roleController, label: 'Посада', hint: 'Комірник'),
          const SizedBox(height: 12),
          _FormField(controller: deptController, label: 'Відділ', hint: 'Склад'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text('Скасувати'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: AppColors.brand),
          onPressed: () {
            final name = nameController.text.trim();
            if (name.isEmpty) return;
            Navigator.of(ctx).pop({
              'name': name,
              'role': roleController.text.trim(),
              'dept': deptController.text.trim(),
            });
          },
          child: Text(initialName.isEmpty ? 'Створити' : 'Зберегти'),
        ),
      ],
    ),
  );

  nameController.dispose();
  roleController.dispose();
  deptController.dispose();
  return result;
}

class _FormField extends StatelessWidget {
  const _FormField({
    required this.controller,
    required this.label,
    required this.hint,
  });

  final TextEditingController controller;
  final String label;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
    );
  }
}
