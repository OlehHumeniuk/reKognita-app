import 'package:flutter/material.dart';
import 'package:rekognita_app/core/constants/app_colors.dart';
import 'package:rekognita_app/core/data/mock_data.dart';
import 'package:rekognita_app/features/templates/presentation/providers/templates_controller.dart';
import 'package:rekognita_app/features/templates/presentation/widgets/template_editor.dart';
import 'package:rekognita_app/features/templates/presentation/widgets/template_selector_item.dart';
import 'package:rekognita_app/shared/widgets/section_header.dart';

class TemplatesPage extends StatefulWidget {
  const TemplatesPage({super.key});

  @override
  State<TemplatesPage> createState() => _TemplatesPageState();
}

class _TemplatesPageState extends State<TemplatesPage> {
  late final TemplatesController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TemplatesController();
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
        final current = seedTemplates[_controller.activeIndex];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(
              title: 'Шаблони розпаршування',
              subtitle: 'Налаштування полів екстракції для кожного типу',
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth > 900;
                final selector = Column(
                  children: [
                    ...seedTemplates.asMap().entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: TemplateSelectorItem(
                          template: entry.value,
                          active: entry.key == _controller.activeIndex,
                          onTap: () => _controller.select(entry.key),
                        ),
                      );
                    }),
                    OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(44),
                        side: const BorderSide(
                          color: AppColors.border,
                          width: 1.5,
                        ),
                      ),
                      child: const Text('+ Новий шаблон'),
                    ),
                  ],
                );

                if (wide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(width: 240, child: selector),
                      const SizedBox(width: 16),
                      Expanded(child: TemplateEditor(template: current)),
                    ],
                  );
                }
                return Column(
                  children: [
                    selector,
                    const SizedBox(height: 12),
                    TemplateEditor(template: current),
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
