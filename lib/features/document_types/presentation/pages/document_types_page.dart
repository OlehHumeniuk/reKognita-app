import 'package:flutter/material.dart';
import 'package:rekognita_app/core/constants/app_colors.dart';
import 'package:rekognita_app/core/data/mock_data.dart';
import 'package:rekognita_app/features/document_types/presentation/providers/document_types_controller.dart';
import 'package:rekognita_app/features/document_types/presentation/widgets/document_type_card.dart';
import 'package:rekognita_app/shared/widgets/section_header.dart';

class DocumentTypesPage extends StatefulWidget {
  const DocumentTypesPage({super.key});

  @override
  State<DocumentTypesPage> createState() => _DocumentTypesPageState();
}

class _DocumentTypesPageState extends State<DocumentTypesPage> {
  late final DocumentTypesController _controller;

  @override
  void initState() {
    super.initState();
    _controller = DocumentTypesController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showEditDialog(int id) {
    // TODO: open edit dialog for document type
  }

  void _showTemplateForType(int id) {
    // TODO: navigate to templates tab filtered by this type
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Column(
          children: [
            const SectionHeader(
              title: 'Типи документів',
              subtitle: 'Налаштування категорій та маршрутизації',
              buttonLabel: '+ Новий тип',
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
                  itemCount: seedDocumentTypes.length + 1,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: cols,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    mainAxisExtent: 200,
                  ),
                  itemBuilder: (context, index) {
                    if (index == seedDocumentTypes.length) {
                      return InkWell(
                        onTap: () {},
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
                                    color: AppColors.brand.withValues(alpha: 0.7),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }

                    final doc = seedDocumentTypes[index];
                    return DocumentTypeCard(
                      documentType: doc,
                      active: _controller.activeDocumentTypeId == doc.id,
                      onTap: () => _controller.toggleSelection(doc.id),
                      onEdit: () => _showEditDialog(doc.id),
                      onTemplate: () => _showTemplateForType(doc.id),
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
