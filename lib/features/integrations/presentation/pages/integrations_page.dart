import 'package:flutter/material.dart';
import 'package:rekognita_app/core/constants/app_colors.dart';
import 'package:rekognita_app/features/integrations/domain/entities/integration.dart';
import 'package:rekognita_app/features/integrations/presentation/providers/integrations_controller.dart';
import 'package:rekognita_app/features/integrations/presentation/widgets/integration_card.dart';
import 'package:rekognita_app/shared/widgets/rk_card.dart';
import 'package:rekognita_app/shared/widgets/section_header.dart';

class IntegrationsPage extends StatefulWidget {
  const IntegrationsPage({required this.accessToken, super.key});

  final String accessToken;

  @override
  State<IntegrationsPage> createState() => _IntegrationsPageState();
}

class _IntegrationsPageState extends State<IntegrationsPage> {
  late final IntegrationsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = IntegrationsController(accessToken: widget.accessToken);
    _controller.load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showNewIntegrationSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _NewIntegrationSheet(
        onAdd: (name, status, icon) {
          _controller.create(name: name, status: status, icon: icon);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Column(
          children: [
            SectionHeader(
              title: 'Інтеграції',
              buttonLabel: '+ Нова інтеграція',
              onTap: _showNewIntegrationSheet,
            ),
            const SizedBox(height: 12),
            if (_controller.isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 48),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_controller.error != null &&
                _controller.integrations.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 48),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.cloud_off_rounded,
                          size: 36, color: AppColors.muted),
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
              )
            else ...[
              ..._controller.integrations.map(
                (integration) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: IntegrationCard(
                    integration: integration,
                    onUpdate: _controller.update,
                  ),
                ),
              ),
            ],
            const RkCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Безпека передачі даних',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.dark,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Дані передаються по TLS 1.3. Фото після обробки не зберігаються. '
                    'Self-Hosted контур ізольований від публічних LLM, а Webhook підписується HMAC-SHA256.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.muted,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

// ── New Integration bottom sheet ──────────────────────────────────────────────

class _NewIntegrationSheet extends StatefulWidget {
  const _NewIntegrationSheet({required this.onAdd});

  final void Function(String name, IntegrationStatus status, String icon) onAdd;

  @override
  State<_NewIntegrationSheet> createState() => _NewIntegrationSheetState();
}

class _NewIntegrationSheetState extends State<_NewIntegrationSheet> {
  final _nameCtrl = TextEditingController();
  IntegrationStatus _status = IntegrationStatus.pending;

  static const _icons = ['🔗', '📋', '🏢', '🏥', '👥', '⚙️', '📊', '🔄'];
  String _icon = '🔗';

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  void _add() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    widget.onAdd(name, _status, _icon);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
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

            // Title
            const Text(
              'Нова інтеграція',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.dark,
              ),
            ),
            const SizedBox(height: 24),

            // Icon picker
            const Text(
              'ІКОНКА',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.muted,
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _icons
                  .map((ic) => GestureDetector(
                        onTap: () => setState(() => _icon = ic),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: 40,
                          height: 40,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: _icon == ic
                                ? AppColors.brand.withValues(alpha: 0.12)
                                : AppColors.bg,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: _icon == ic
                                  ? AppColors.brand
                                  : AppColors.border,
                              width: _icon == ic ? 1.5 : 1,
                            ),
                          ),
                          child: Text(ic,
                              style: const TextStyle(fontSize: 18)),
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 20),

            // Name field
            const Text(
              'НАЗВА',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.muted,
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _nameCtrl,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Назва інтеграції',
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: AppColors.brand, width: 1.5),
                ),
                filled: true,
                fillColor: AppColors.bg,
              ),
            ),
            const SizedBox(height: 20),

            // Status selector
            const Text(
              'СТАТУС',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.muted,
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                for (final s in IntegrationStatus.values)
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: s != IntegrationStatus.values.last ? 8 : 0,
                      ),
                      child: _StatusChip(
                        status: s,
                        selected: _status == s,
                        onTap: () => setState(() => _status = s),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _add,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.brand,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Додати',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Status chip ────────────────────────────────────────────────────────────────

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.status,
    required this.selected,
    required this.onTap,
  });

  final IntegrationStatus status;
  final bool selected;
  final VoidCallback onTap;

  static Color _colorOf(IntegrationStatus s) => switch (s) {
        IntegrationStatus.connected => AppColors.success,
        IntegrationStatus.pending => AppColors.warning,
        IntegrationStatus.disconnected => AppColors.danger,
      };

  static String _labelOf(IntegrationStatus s) => switch (s) {
        IntegrationStatus.connected => 'Підключено',
        IntegrationStatus.pending => 'Очікує',
        IntegrationStatus.disconnected => 'Відключено',
      };

  @override
  Widget build(BuildContext context) {
    final color = _colorOf(status);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.12) : AppColors.bg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? color : AppColors.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Center(
          child: Text(
            _labelOf(status),
            style: TextStyle(
              fontSize: 11,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: selected ? color : AppColors.muted,
            ),
          ),
        ),
      ),
    );
  }
}
