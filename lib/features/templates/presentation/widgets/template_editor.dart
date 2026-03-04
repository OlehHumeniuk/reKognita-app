import 'package:flutter/material.dart';
import 'package:rekognita_app/core/constants/app_colors.dart';
import 'package:rekognita_app/features/integrations/domain/entities/integration.dart';
import 'package:rekognita_app/features/templates/domain/entities/parsing_template.dart';
import 'package:rekognita_app/features/templates/domain/entities/template_field.dart';
import 'package:rekognita_app/shared/widgets/rk_card.dart';

// ---------------------------------------------------------------------------
// Public widget
// ---------------------------------------------------------------------------

class TemplateEditor extends StatefulWidget {
  const TemplateEditor({
    required this.template,
    this.isSaving = false,
    this.onSave,
    this.integrations = const [],
    super.key,
  });

  final ParsingTemplate template;
  final bool isSaving;
  final void Function(
      String docType, List<TemplateField> fields, String? integration)? onSave;
  final List<Integration> integrations;

  @override
  State<TemplateEditor> createState() => _TemplateEditorState();
}

class _TemplateEditorState extends State<TemplateEditor> {
  late List<TemplateField> _fields;
  String? _selectedIntegration;
  late TextEditingController _nameCtrl;

  @override
  void initState() {
    super.initState();
    _fields = List.of(widget.template.fields);
    _selectedIntegration = widget.template.integration;
    _nameCtrl = TextEditingController(text: widget.template.docType);
  }

  @override
  void didUpdateWidget(TemplateEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.template.id != widget.template.id) {
      setState(() {
        _fields = List.of(widget.template.fields);
        _selectedIntegration = widget.template.integration;
        _nameCtrl.text = widget.template.docType;
      });
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  void _removeField(int index) => setState(() => _fields.removeAt(index));

  void _updateField(int index, TemplateField updated) =>
      setState(() => _fields[index] = updated);

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex--;
      final item = _fields.removeAt(oldIndex);
      _fields.insert(newIndex, item);
    });
  }

  void _addField(FieldType type) {
    setState(() {
      _fields.add(
        TemplateField(
          name: switch (type) {
            FieldType.text => 'Нове поле',
            FieldType.table => 'Нова таблиця',
            FieldType.formula => 'Нова формула',
            FieldType.image => 'Нове зображення',
          },
          type: type,
        ),
      );
    });
  }

  void _showAddSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _AddFieldSheet(
        onSelected: (type) {
          Navigator.of(context).pop();
          _addField(type);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RkCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _nameCtrl,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.dark,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              FilledButton(
                onPressed: widget.isSaving
                    ? null
                    : () => widget.onSave?.call(
                          _nameCtrl.text.trim().isEmpty
                              ? widget.template.docType
                              : _nameCtrl.text.trim(),
                          _fields,
                          _selectedIntegration,
                        ),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.brand,
                ),
                child: widget.isSaving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Зберегти'),
              ),
            ],
          ),
          if (widget.integrations.isNotEmpty) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                const Text(
                  'ІНТЕГРАЦІЯ',
                  style: TextStyle(
                    fontSize: 11,
                    letterSpacing: 0.8,
                    color: AppColors.muted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.bg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: DropdownButton<String?>(
                      value: _selectedIntegration,
                      isExpanded: true,
                      underline: const SizedBox.shrink(),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.dark,
                      ),
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Center(
                            child: Text(
                              'Не вибрано',
                              style: TextStyle(
                                  color: AppColors.muted,
                                  fontWeight: FontWeight.w400),
                            ),
                          ),
                        ),
                        ...widget.integrations.map(
                          (i) => DropdownMenuItem<String?>(
                            value: i.name,
                            child: Row(
                              children: [
                                Text(i.icon,
                                    style: const TextStyle(fontSize: 14)),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(i.name,
                                      overflow: TextOverflow.ellipsis),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                      onChanged: (v) =>
                          setState(() => _selectedIntegration = v),
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 18),
          const Text(
            'ПОЛЯ ДЛЯ ЕКСТРАКЦІЇ',
            style: TextStyle(
              fontSize: 11,
              letterSpacing: 0.8,
              color: AppColors.muted,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),

          // Field rows
          ReorderableListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            buildDefaultDragHandles: false,
            onReorder: _onReorder,
            proxyDecorator: (child, index, animation) => Material(
              color: Colors.transparent,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: child,
                ),
              ),
            ),
            children: _fields.asMap().entries.map((entry) {
              return Padding(
                key: ValueKey('${widget.template.id}_${entry.key}'),
                padding: const EdgeInsets.only(bottom: 8),
                child: _FieldRow(
                  field: entry.value,
                  index: entry.key,
                  onRemove: () => _removeField(entry.key),
                  onChanged: (updated) => _updateField(entry.key, updated),
                ),
              );
            }).toList(),
          ),

          // Add field button
          OutlinedButton(
            onPressed: _showAddSheet,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(44),
              foregroundColor: AppColors.brand,
              backgroundColor: AppColors.brand.withValues(alpha: 0.05),
              side: const BorderSide(color: AppColors.brand, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              '+ Додати поле',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Field row
// ---------------------------------------------------------------------------

class _FieldRow extends StatefulWidget {
  const _FieldRow({
    required this.field,
    required this.index,
    required this.onRemove,
    required this.onChanged,
  });

  final TemplateField field;
  final int index;
  final VoidCallback onRemove;
  final ValueChanged<TemplateField> onChanged;

  @override
  State<_FieldRow> createState() => _FieldRowState();
}

class _FieldRowState extends State<_FieldRow> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _sigCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.field.name);
    _sigCtrl =
        TextEditingController(text: widget.field.signatureLabel ?? '');
  }

  @override
  void didUpdateWidget(_FieldRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.field.name != widget.field.name &&
        _nameCtrl.text != widget.field.name) {
      _nameCtrl.text = widget.field.name;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _sigCtrl.dispose();
    super.dispose();
  }

  void _addColumn(String col) {
    if (col.trim().isEmpty) return;
    widget.onChanged(
      widget.field.copyWith(
        tableColumns: [...widget.field.tableColumns, col.trim()],
      ),
    );
  }

  void _removeColumn(int i) {
    final cols = List<String>.of(widget.field.tableColumns)..removeAt(i);
    widget.onChanged(widget.field.copyWith(tableColumns: cols));
  }

  @override
  Widget build(BuildContext context) {
    final type = widget.field.type;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main row
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
            child: Row(
              children: [
                ReorderableDragStartListener(
                  index: widget.index,
                  child: const Icon(
                    Icons.drag_indicator_rounded,
                    color: AppColors.brand,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _nameCtrl,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.dark,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onChanged: (v) =>
                        widget.onChanged(widget.field.copyWith(name: v)),
                  ),
                ),
                const SizedBox(width: 8),
                // Type badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: type.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(type.icon, size: 12, color: type.color),
                      const SizedBox(width: 4),
                      Text(
                        type.label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: type.color,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: widget.onRemove,
                  icon: const Icon(
                    Icons.close_rounded,
                    color: AppColors.muted,
                    size: 18,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                  ),
                ),
              ],
            ),
          ),

          // Sub-section: table columns
          if (type == FieldType.table) _buildTableSection(),

          // Sub-section: formula / image signature
          if (type == FieldType.formula || type == FieldType.image)
            _buildSignatureSection(),
        ],
      ),
    );
  }

  Widget _buildTableSection() {
    final type = widget.field.type;
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: type.color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Колонки таблиці',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: type.color,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              ...widget.field.tableColumns.asMap().entries.map(
                (e) => _ColumnChip(
                  label: e.value,
                  color: type.color,
                  onRemove: () => _removeColumn(e.key),
                ),
              ),
              _AddColumnChip(onAdd: _addColumn),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSignatureSection() {
    final type = widget.field.type;
    final isFormula = type == FieldType.formula;
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: type.color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(
            isFormula ? Icons.edit_rounded : Icons.label_rounded,
            size: 13,
            color: type.color,
          ),
          const SizedBox(width: 6),
          Text(
            isFormula ? 'Підпис формули:' : 'Підпис зображення:',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: type.color,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _sigCtrl,
              style: const TextStyle(fontSize: 12, color: AppColors.dark),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: isFormula ? 'напр. М.П.' : 'напр. Директор',
                hintStyle: const TextStyle(
                  fontSize: 12,
                  color: AppColors.muted,
                ),
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: (v) => widget.onChanged(
                widget.field.copyWith(signatureLabel: v),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Column chips
// ---------------------------------------------------------------------------

class _ColumnChip extends StatelessWidget {
  const _ColumnChip({
    required this.label,
    required this.color,
    required this.onRemove,
  });

  final String label;
  final Color color;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: Icon(Icons.close_rounded, size: 12, color: color),
          ),
        ],
      ),
    );
  }
}

class _AddColumnChip extends StatefulWidget {
  const _AddColumnChip({required this.onAdd});

  final ValueChanged<String> onAdd;

  @override
  State<_AddColumnChip> createState() => _AddColumnChipState();
}

class _AddColumnChipState extends State<_AddColumnChip> {
  bool _editing = false;
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _submit() {
    widget.onAdd(_ctrl.text);
    _ctrl.clear();
    setState(() => _editing = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_editing) {
      return SizedBox(
        width: 110,
        height: 28,
        child: TextField(
          controller: _ctrl,
          autofocus: true,
          style: const TextStyle(fontSize: 12),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide:
                  BorderSide(color: AppColors.brand.withValues(alpha: 0.4)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: AppColors.brand),
            ),
            isDense: true,
            hintText: 'Назва',
            hintStyle: const TextStyle(fontSize: 12, color: AppColors.muted),
          ),
          onSubmitted: (_) => _submit(),
          onTapOutside: (_) => setState(() => _editing = false),
        ),
      );
    }

    return GestureDetector(
      onTap: () => setState(() => _editing = true),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border, width: 1.5),
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_rounded, size: 13, color: AppColors.muted),
            SizedBox(width: 3),
            Text(
              'Додати',
              style: TextStyle(fontSize: 12, color: AppColors.muted),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Add field bottom sheet
// ---------------------------------------------------------------------------

class _AddFieldSheet extends StatelessWidget {
  const _AddFieldSheet({required this.onSelected});

  final void Function(FieldType) onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        20 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
          const Text(
            'Оберіть тип поля',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.dark,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Що потрібно витягнути з документа?',
            style: TextStyle(fontSize: 13, color: AppColors.muted),
          ),
          const SizedBox(height: 16),
          ...FieldType.values.map(
            (type) => _TypeOptionCard(
              type: type,
              onTap: () => onSelected(type),
            ),
          ),
        ],
      ),
    );
  }
}

class _TypeOptionCard extends StatelessWidget {
  const _TypeOptionCard({required this.type, required this.onTap});

  final FieldType type;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: type.color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: type.color.withValues(alpha: 0.22)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: type.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(type.icon, color: type.color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    type.label,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.dark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    type.description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 13,
              color: type.color,
            ),
          ],
        ),
      ),
    );
  }
}
