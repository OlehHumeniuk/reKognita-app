import 'package:core_ui/core_ui.dart' hide AppColors;
import 'package:flutter/material.dart';
import 'package:rekognita_app/core/constants/app_colors.dart';
import 'package:rekognita_app/features/integrations/presentation/providers/integrations_controller.dart';
import 'package:rekognita_app/features/templates/domain/entities/template_field.dart';
import 'package:rekognita_app/features/templates/presentation/providers/templates_controller.dart';
import 'package:rekognita_app/features/templates/presentation/widgets/template_editor.dart';
import 'package:rekognita_app/features/templates/presentation/widgets/template_selector_item.dart';
import 'package:rekognita_app/shared/widgets/section_header.dart';

class DocumentTypesPage extends StatefulWidget {
  const DocumentTypesPage({required this.accessToken, super.key});

  final String accessToken;

  @override
  State<DocumentTypesPage> createState() => _DocumentTypesPageState();
}

class _DocumentTypesPageState extends State<DocumentTypesPage> {
  late final TemplatesController _controller;
  late final IntegrationsController _integrationsCtrl;

  @override
  void initState() {
    super.initState();
    _controller = TemplatesController(accessToken: widget.accessToken);
    _integrationsCtrl = IntegrationsController(accessToken: widget.accessToken);
    _controller.load();
    _integrationsCtrl.load();
  }

  @override
  void dispose() {
    _controller.dispose();
    _integrationsCtrl.dispose();
    super.dispose();
  }

  Future<void> _showNewTypeDialog() async {
    final name = await CustomInputDialog.showTextInput(
      context: context,
      title: 'Новий тип документа',
      subtitle: 'Введіть назву типу документа',
      cancelButtonText: 'Скасувати',
      actionButtonText: 'Створити',
      hintText: 'напр. Накладні, Договори...',
      actionButtonColor: AppColors.brand,
      actionButtonHoverColor: AppColors.brandLight,
      actionButtonSplashColor: AppColors.brandLight,
      actionButtonTextColor: AppColors.white,
    );
    if (name != null && name.isNotEmpty) {
      _controller.createTemplate(name);
    }
  }

  Future<void> _onSave(
      int id, String docType, List<TemplateField> fields, String? integration) async {
    await _controller.saveAll(
        id: id, docType: docType, fields: fields, integration: integration);
    if (!mounted) return;
    final err = _controller.error;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(err ?? 'Збережено'),
        backgroundColor: err != null ? AppColors.danger : AppColors.success,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_controller, _integrationsCtrl]),
      builder: (context, _) {
        if (_controller.isLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 64),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (_controller.error != null && _controller.templates.isEmpty) {
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
                    style:
                        FilledButton.styleFrom(backgroundColor: AppColors.brand),
                    child: const Text('Повторити'),
                  ),
                ],
              ),
            ),
          );
        }

        final templates = _controller.templates;
        final activeIndex = _controller.activeIndex;
        final current = activeIndex != null ? templates[activeIndex] : null;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              title: 'Типи документів',
              subtitle: 'Поля екстракції та інтеграція для кожного типу',
              buttonLabel: '+ Новий тип',
              onTap: _showNewTypeDialog,
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth > 900;

                final selector = Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      clipBehavior: Clip.hardEdge,
                      child: Column(
                        children: [
                          ...templates.asMap().entries.map((entry) {
                            final isLast = entry.key == templates.length - 1;
                            return Column(
                              children: [
                                TemplateSelectorItem(
                                  template: entry.value,
                                  active: entry.key == activeIndex,
                                  onTap: () => _controller.select(entry.key),
                                ),
                                if (!isLast)
                                  const Divider(
                                    height: 1,
                                    thickness: 1,
                                    color: AppColors.border,
                                    indent: 29,
                                  ),
                              ],
                            );
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton(
                      onPressed: _showNewTypeDialog,
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(44),
                        foregroundColor: AppColors.brand,
                        backgroundColor:
                            AppColors.brand.withValues(alpha: 0.05),
                        side: const BorderSide(
                            color: AppColors.brand, width: 1.5),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text(
                        '+ Новий тип',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                );

                final editor = current == null
                    ? null
                    : TemplateEditor(
                        template: current,
                        isSaving: _controller.isSaving,
                        onSave: (docType, fields, integration) =>
                            _onSave(current.id, docType, fields, integration),
                        integrations: _integrationsCtrl.integrations,
                      );

                if (wide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(width: 240, child: selector),
                      if (editor != null) ...[
                        const SizedBox(width: 16),
                        Expanded(child: editor),
                      ],
                    ],
                  );
                }

                return Column(
                  children: [
                    selector,
                    if (editor != null) ...[
                      const SizedBox(height: 12),
                      editor,
                    ],
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

