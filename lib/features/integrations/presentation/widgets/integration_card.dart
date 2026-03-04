import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rekognita_app/core/constants/app_colors.dart';
import 'package:rekognita_app/features/integrations/domain/entities/integration.dart';
import 'package:rekognita_app/features/integrations/presentation/widgets/integration_status_badge.dart';
import 'package:rekognita_app/shared/widgets/rk_badge.dart';
import 'package:rekognita_app/shared/widgets/rk_card.dart';

class IntegrationCard extends StatelessWidget {
  const IntegrationCard({
    required this.integration,
    required this.onUpdate,
    super.key,
  });

  final Integration integration;
  final ValueChanged<Integration> onUpdate;

  String get _webhookUrl {
    final slug = integration.name
        .toLowerCase()
        .replaceAll(RegExp(r'[\s/]+'), '-')
        .replaceAll(RegExp(r'[^a-z0-9-]'), '');
    return 'api.rekognita.io/wh/$slug';
  }

  void _showSettingsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _IntegrationSettingsSheet(
        integration: integration,
        webhookUrl: integration.webhookUrl ?? _webhookUrl,
        onSave: onUpdate,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        RkCard(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: integration.color.withValues(alpha: 0.15),
                ),
                alignment: Alignment.center,
                child: Text(
                  integration.icon,
                  style: const TextStyle(fontSize: 22),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 32),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          Text(
                            integration.name,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppColors.dark,
                            ),
                          ),
                          IntegrationStatusBadge(status: integration.status),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: integration.types
                          .map((type) => RkBadge(text: type))
                          .toList(growable: false),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.brand.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        integration.webhookUrl ?? _webhookUrl,
                        style: const TextStyle(
                          color: AppColors.brand,
                          fontSize: 11,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: IconButton(
            onPressed: () => _showSettingsSheet(context),
            tooltip: 'Налаштувати',
            iconSize: 18,
            style: IconButton.styleFrom(
              minimumSize: const Size(32, 32),
              padding: EdgeInsets.zero,
              foregroundColor: AppColors.muted,
            ),
            icon: const Icon(Icons.settings_rounded),
          ),
        ),
      ],
    );
  }
}

// ── Settings / edit bottom sheet ──────────────────────────────────────────────

class _IntegrationSettingsSheet extends StatefulWidget {
  const _IntegrationSettingsSheet({
    required this.integration,
    required this.webhookUrl,
    required this.onSave,
  });

  final Integration integration;
  final String webhookUrl;
  final ValueChanged<Integration> onSave;

  @override
  State<_IntegrationSettingsSheet> createState() =>
      _IntegrationSettingsSheetState();
}

class _IntegrationSettingsSheetState
    extends State<_IntegrationSettingsSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _webhookCtrl;
  late IntegrationStatus _status;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.integration.name);
    _webhookCtrl = TextEditingController(text: widget.webhookUrl);
    _status = widget.integration.status;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _webhookCtrl.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    final webhook = _webhookCtrl.text.trim();
    widget.onSave(
      Integration(
        id: widget.integration.id,
        name: name,
        status: _status,
        types: widget.integration.types,
        icon: widget.integration.icon,
        color: widget.integration.color,
        webhookUrl: webhook.isEmpty ? null : webhook,
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
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

            // Header
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: widget.integration.color
                        .withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    widget.integration.icon,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Налаштування інтеграції',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.dark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

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
              decoration: InputDecoration(
                hintText: 'Назва інтеграції',
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12),
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
                  borderSide: const BorderSide(
                      color: AppColors.brand, width: 1.5),
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
                        right:
                            s != IntegrationStatus.values.last ? 8 : 0,
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
            const SizedBox(height: 20),

            // Webhook URL (editable + copy)
            const Text(
              'WEBHOOK URL',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.muted,
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _webhookCtrl,
              style: const TextStyle(
                fontSize: 12,
                fontFamily: 'monospace',
                color: AppColors.dark,
              ),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12),
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
                  borderSide: const BorderSide(
                      color: AppColors.brand, width: 1.5),
                ),
                filled: true,
                fillColor: AppColors.bg,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.copy_rounded,
                      size: 16, color: AppColors.muted),
                  onPressed: () {
                    Clipboard.setData(
                        ClipboardData(text: _webhookCtrl.text));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('URL скопійовано'),
                        duration: Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 28),

            // Save button
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _save,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.brand,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Зберегти',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Status chip ───────────────────────────────────────────────────────────────

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
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        decoration: BoxDecoration(
          color: selected
              ? color.withValues(alpha: 0.12)
              : AppColors.bg,
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
              fontWeight:
                  selected ? FontWeight.w700 : FontWeight.w500,
              color: selected ? color : AppColors.muted,
            ),
          ),
        ),
      ),
    );
  }
}
