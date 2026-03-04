import 'package:core_ui/core_ui.dart' hide AppColors;
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:rekognita_app/core/constants/app_colors.dart';
import 'package:rekognita_app/features/dashboard/domain/entities/doc_record.dart';
import 'package:rekognita_app/features/team/domain/entities/employee.dart';
import 'package:rekognita_app/features/team/presentation/providers/team_controller.dart';
import 'package:rekognita_app/features/team/presentation/widgets/team_details_card.dart';
import 'package:rekognita_app/features/team/presentation/widgets/team_member_tile.dart';
import 'package:rekognita_app/features/templates/data/templates_api_client.dart';
import 'package:rekognita_app/shared/widgets/rk_card.dart';
import 'package:rekognita_app/shared/widgets/section_header.dart';

class TeamPage extends StatefulWidget {
  const TeamPage({required this.accessToken, super.key});

  final String accessToken;

  @override
  State<TeamPage> createState() => _TeamPageState();
}

class _TeamPageState extends State<TeamPage> {
  late final TeamController _controller;
  final _templatesApi = TemplatesApiClient();
  List<String> _availableDocTypes = [];

  @override
  void initState() {
    super.initState();
    _controller = TeamController(accessToken: widget.accessToken);
    _controller.load();
    _loadDocTypes();
  }

  Future<void> _loadDocTypes() async {
    try {
      final templates = await _templatesApi.fetchAll(token: widget.accessToken);
      if (mounted) {
        setState(() {
          _availableDocTypes = templates
              .map((t) => t.docType)
              .toList(growable: false);
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _showCreateDialog() async {
    final result = await _showEmployeeFormDialog(context);
    if (result == null) return;
    await _controller.createEmployee(
      name: result.name,
      role: result.role,
      dept: result.dept,
    );
    final created = _controller.selected;
    if (created?.inviteCode != null && mounted) {
      _showQrDialog(created!);
    }
  }

  void _showQrDialog(Employee employee) {
    showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                width: double.infinity,
                color: AppColors.brand,
                padding: const EdgeInsets.fromLTRB(16, 16, 24, 16),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Icon(
                        Icons.qr_code_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    Text(
                      '${employee.name}  •  ${employee.role}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.2,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // QR code
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 18, 24, 12),
                child: QrImageView(
                  data: employee.inviteCode!,
                  size: 285,
                  backgroundColor: Colors.white,
                ),
              ),
              const Text(
                'Відскануйте у додатку ReKognita Employee',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.muted,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.brand,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Готово'),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showEditDialog(Employee employee) async {
    final result = await _showEmployeeFormDialog(
      context,
      initialName: employee.name,
      initialRole: employee.role,
      initialDept: employee.dept,
      availableDocTypes: _availableDocTypes,
      initialDocs: employee.docs,
    );
    if (result == null || !mounted) return;

    await _controller.updateEmployee(
      id: employee.id,
      name: result.name,
      role: result.role,
      dept: result.dept,
    );

    for (final doc in result.docs) {
      if (!employee.docs.contains(doc)) {
        await _controller.addDoc(employee.id, doc);
      }
    }
    for (final doc in employee.docs) {
      if (!result.docs.contains(doc)) {
        await _controller.removeDoc(employee.id, doc);
      }
    }
  }

  void _showDocsDialog(Employee employee, List<DocRecord>? docs) {
    showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                color: AppColors.brand,
                padding: const EdgeInsets.fromLTRB(16, 16, 24, 16),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Icon(
                        Icons.description_outlined,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    Text(
                      employee.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 14, 16, 4),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'ОСТАННІ ДОКУМЕНТИ',
                    style: TextStyle(
                      fontSize: 11,
                      letterSpacing: 0.7,
                      color: AppColors.muted,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              if (docs == null || docs.isEmpty)
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 8, 16, 20),
                  child: Text(
                    'Немає записів',
                    style: TextStyle(fontSize: 13, color: AppColors.muted),
                  ),
                )
              else
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 320),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                    child: Column(
                      children: docs
                          .map(
                            (r) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Row(
                                children: [
                                  Text(
                                    r.typeIcon,
                                    style: const TextStyle(fontSize: 18),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          r.docNumber,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.dark,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          r.timeAgo,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: AppColors.muted,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 7,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: r.status.color.withValues(
                                        alpha: 0.12,
                                      ),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      r.status.label,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: r.status.color,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(growable: false),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.brand,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Закрити'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(int id, String name) async {
    final confirmed = await CustomAlertDialog.show(
      context: context,
      title: 'Видалити співробітника?',
      content: '$name буде видалено назавжди. Цю дію неможливо скасувати.',
      cancelButtonText: 'Скасувати',
      actionButtonText: 'Видалити',
      actionType: DialogActionType.danger,
    );
    if (confirmed == true && mounted) {
      await _controller.deleteEmployee(id);
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

        if (_controller.error != null &&
            _controller.filteredEmployees.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 64),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.cloud_off_rounded,
                    size: 40,
                    color: AppColors.muted,
                  ),
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
                      backgroundColor: AppColors.brand,
                    ),
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
              isLoadingDocs: _controller.isLoadingDocs,
              recentDocs: selected != null
                  ? _controller.docsFor(selected.id)
                  : null,
              onShowDocs: selected != null
                  ? () => _showDocsDialog(
                      selected,
                      _controller.docsFor(selected.id),
                    )
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
              onEdit: () => _showEditDialog(employee),
              onToggleStatus: () => _controller.toggleStatus(employee.id),
              onDelete: () => _confirmDelete(employee.id, employee.name),
              onShowQr: employee.inviteCode != null
                  ? () => _showQrDialog(employee)
                  : null,
            ),
          );
        }),
      ],
    );
  }
}

class _EmployeeFormResult {
  const _EmployeeFormResult({
    required this.name,
    required this.role,
    required this.dept,
    this.docs = const [],
  });
  final String name;
  final String role;
  final String dept;
  final List<String> docs;
}

Future<_EmployeeFormResult?> _showEmployeeFormDialog(
  BuildContext context, {
  String initialName = '',
  String initialRole = '',
  String initialDept = '',
  List<String> availableDocTypes = const [],
  List<String> initialDocs = const [],
}) {
  return showDialog<_EmployeeFormResult>(
    context: context,
    builder: (ctx) => _EmployeeFormDialog(
      initialName: initialName,
      initialRole: initialRole,
      initialDept: initialDept,
      availableDocTypes: availableDocTypes,
      initialDocs: initialDocs,
    ),
  );
}

class _EmployeeFormDialog extends StatefulWidget {
  const _EmployeeFormDialog({
    this.initialName = '',
    this.initialRole = '',
    this.initialDept = '',
    this.availableDocTypes = const [],
    this.initialDocs = const [],
  });

  final String initialName;
  final String initialRole;
  final String initialDept;
  final List<String> availableDocTypes;
  final List<String> initialDocs;

  @override
  State<_EmployeeFormDialog> createState() => _EmployeeFormDialogState();
}

class _EmployeeFormDialogState extends State<_EmployeeFormDialog> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _roleCtrl;
  late final TextEditingController _deptCtrl;
  late List<String> _docs;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.initialName);
    _roleCtrl = TextEditingController(text: widget.initialRole);
    _deptCtrl = TextEditingController(text: widget.initialDept);
    _docs = List.of(widget.initialDocs);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _roleCtrl.dispose();
    _deptCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    Navigator.of(context).pop(
      _EmployeeFormResult(
        name: name,
        role: _roleCtrl.text.trim(),
        dept: _deptCtrl.text.trim(),
        docs: List.of(_docs),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initialName.isNotEmpty;
    final unassigned = widget.availableDocTypes
        .where((t) => !_docs.contains(t))
        .toList(growable: false);

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Header ──────────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: AppColors.brand,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(24, 22, 24, 22),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        isEdit
                            ? Icons.edit_outlined
                            : Icons.person_add_outlined,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                  Text(
                    isEdit ? 'Редагувати' : 'Новий співробітник',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
            ),

            // ── Body ────────────────────────────────────────────
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _FormField(
                      controller: _nameCtrl,
                      label: "Ім'я та прізвище",
                      hint: 'Олексій Коваль',
                      icon: Icons.person_outline_rounded,
                    ),
                    const SizedBox(height: 10),
                    _FormField(
                      controller: _roleCtrl,
                      label: 'Посада',
                      hint: 'Комірник',
                      icon: Icons.badge_outlined,
                    ),
                    const SizedBox(height: 10),
                    _FormField(
                      controller: _deptCtrl,
                      label: 'Відділ',
                      hint: 'Склад',
                      icon: Icons.apartment_rounded,
                    ),

                    // ── Doc types — edit only ──────────────────
                    if (isEdit && widget.availableDocTypes.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Container(
                            width: 3,
                            height: 18,
                            decoration: BoxDecoration(
                              color: AppColors.brand,
                              borderRadius: BorderRadius.circular(99),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'ДОСТУП ДО ТИПІВ',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.dark,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Assigned
                      if (_docs.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 14,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.bg,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'Немає призначених типів',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.muted,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        )
                      else
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: _docs
                              .map(
                                (doc) => _DocTag(
                                  label: doc,
                                  onRemove: () =>
                                      setState(() => _docs.remove(doc)),
                                ),
                              )
                              .toList(growable: false),
                        ),

                      // Available to add
                      if (unassigned.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        const Text(
                          'Додати:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.dark,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: unassigned
                              .map(
                                (doc) => _DocAddTag(
                                  label: doc,
                                  onAdd: () => setState(() => _docs.add(doc)),
                                ),
                              )
                              .toList(growable: false),
                        ),
                      ],
                      const SizedBox(height: 4),
                    ],
                  ],
                ),
              ),
            ),

            // ── Actions ─────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(
                            color: AppColors.brand,
                            width: 1.5,
                          ),
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text(
                        'Скасувати',
                        style: TextStyle(
                          color: AppColors.brand,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.brand,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _submit,
                      child: Text(
                        isEdit ? 'Зберегти зміни' : 'Створити',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DocTag extends StatelessWidget {
  const _DocTag({required this.label, required this.onRemove});
  final String label;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 12, right: 6, top: 6, bottom: 6),
      decoration: BoxDecoration(
        color: AppColors.brand,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF1D4ED8), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.brand.withValues(alpha: 0.25),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: -0.1,
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5),
              ),
              child: const Icon(
                Icons.close_rounded,
                size: 13,
                color: AppColors.brand,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DocAddTag extends StatelessWidget {
  const _DocAddTag({required this.label, required this.onAdd});
  final String label;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onAdd,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.bg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AppColors.brand.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: AppColors.brand,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(
                Icons.add_rounded,
                size: 12,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.brand,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  const _FormField({
    required this.controller,
    required this.label,
    required this.hint,
    this.icon,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.dark,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: icon != null
            ? Icon(icon, size: 20, color: AppColors.dark)
            : null,
        filled: true,
        fillColor: AppColors.bg,
        labelStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w900,
          color: AppColors.dark,
        ),
        hintStyle: const TextStyle(fontSize: 13, color: AppColors.border),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 13,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.brand, width: 1.5),
        ),
      ),
    );
  }
}
