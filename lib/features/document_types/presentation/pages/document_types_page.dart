import 'package:core_ui/core_ui.dart' hide AppColors;
import 'package:flutter/material.dart';
import 'package:rekognita_app/app/router/app_router.dart';
import 'package:rekognita_app/core/constants/app_colors.dart';
import 'package:rekognita_app/features/document_types/presentation/providers/document_types_controller.dart';
import 'package:rekognita_app/features/document_types/presentation/widgets/document_type_card.dart';
import 'package:rekognita_app/shared/widgets/section_header.dart';

class DocumentTypesPage extends StatefulWidget {
  const DocumentTypesPage({
    required this.accessToken,
    this.onNavigateToSection,
    super.key,
  });

  final String accessToken;
  final ValueChanged<AppSection>? onNavigateToSection;

  @override
  State<DocumentTypesPage> createState() => _DocumentTypesPageState();
}

class _DocumentTypesPageState extends State<DocumentTypesPage> {
  late final DocumentTypesController _controller;

  @override
  void initState() {
    super.initState();
    _controller = DocumentTypesController(accessToken: widget.accessToken);
    _controller.load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _showCreateDialog() async {
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
      _controller.createType(name);
    }
  }

  Future<void> _showEditDialog(int id) async {
    final type = _controller.types.firstWhere((t) => t.id == id);
    final name = await CustomInputDialog.showTextInput(
      context: context,
      title: 'Редагувати тип',
      subtitle: 'Змініть назву типу документа',
      cancelButtonText: 'Скасувати',
      actionButtonText: 'Зберегти',
      hintText: 'Назва типу документа',
      initialValue: type.name,
      actionButtonColor: AppColors.brand,
      actionButtonHoverColor: AppColors.brandLight,
      actionButtonSplashColor: AppColors.brandLight,
      actionButtonTextColor: AppColors.white,
    );
    if (name != null && name.isNotEmpty) {
      _controller.editName(id, name);
    }
  }

  void _navigateToTemplates() {
    widget.onNavigateToSection?.call(AppSection.templates);
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

        if (_controller.error != null && _controller.types.isEmpty) {
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

        final types = _controller.types;
        return Column(
          children: [
            SectionHeader(
              title: 'Типи документів',
              subtitle: 'Налаштування категорій та маршрутизації',
              buttonLabel: '+ Новий тип',
              onTap: _showCreateDialog,
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final cols = constraints.maxWidth > 1150
                    ? 3
                    : constraints.maxWidth > 720
                        ? 2
                        : 1;
                return GridView.builder(
                  itemCount: types.length + 1,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: cols,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    mainAxisExtent: 200,
                  ),
                  itemBuilder: (context, index) {
                    if (index == types.length) {
                      return InkWell(
                        onTap: _showCreateDialog,
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.brand.withValues(alpha: 0.3),
                              width: 2,
                              strokeAlign: BorderSide.strokeAlignInside,
                            ),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.add_rounded,
                                  size: 28,
                                  color: AppColors.brand.withValues(alpha: 0.5),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Додати тип',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color:
                                        AppColors.brand.withValues(alpha: 0.7),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }

                    final doc = types[index];
                    return DocumentTypeCard(
                      documentType: doc,
                      active: _controller.activeDocumentTypeId == doc.id,
                      onTap: () => _controller.toggleSelection(doc.id),
                      onEdit: () => _showEditDialog(doc.id),
                      onTemplate: _navigateToTemplates,
                    );
                  },
                );
              },
            ),
          ],
        );
      },
    );
  }
}
