import 'package:flutter/material.dart';
import 'package:rekognita_app/core/constants/app_colors.dart';
import 'package:rekognita_app/features/dashboard/domain/entities/doc_record.dart';

class DocRecordPage extends StatefulWidget {
  const DocRecordPage({required this.record, super.key});

  final DocRecord record;

  @override
  State<DocRecordPage> createState() => _DocRecordPageState();
}

class _DocRecordPageState extends State<DocRecordPage> {
  bool _isRequesting = false;
  bool _requestDone = false;
  String? _integrationRef;

  bool _isSrmLoading = false;
  bool _srmDone = false;
  String? _srmDocUrl;

  DocRecord get record => widget.record;

  Future<void> _sendIntegrationRequest() async {
    setState(() => _isRequesting = true);
    // Simulate network request to 1C / external system
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _isRequesting = false;
      _requestDone = true;
      _integrationRef =
          '${record.integrationSystem.replaceAll('/', '-')}-2024-${record.id.split('-').last.padLeft(4, '0')}';
    });
  }

  Future<void> _loadFromSrm() async {
    setState(() => _isSrmLoading = true);
    // Simulate SRM document fetch
    await Future.delayed(const Duration(milliseconds: 1800));
    setState(() {
      _isSrmLoading = false;
      _srmDone = true;
      _srmDocUrl = 'SRM-DOC-${record.id.split('-').last.toUpperCase().padLeft(5, '0')}';
    });
  }

  @override
  Widget build(BuildContext context) {
    final color = record.typeColor;
    final status = record.status;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 165,
            pinned: true,
            backgroundColor: color,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      color.withValues(alpha: 0.85),
                      color,
                    ],
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(20, 80, 20, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          record.typeIcon,
                          style: const TextStyle(fontSize: 22),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            record.docNumber,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: status.color,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: status.color.withValues(alpha: 0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(status.icon, size: 11, color: Colors.white),
                              const SizedBox(width: 4),
                              Text(
                                status.label,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${record.docType} • ${record.uploadedBy} • ${record.timeAgo}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.75),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Extracted fields
                  _SectionCard(
                    title: 'Витягнуті дані',
                    icon: Icons.data_object_rounded,
                    child: Column(
                      children: record.extractedFields.entries
                          .toList()
                          .asMap()
                          .entries
                          .map((entry) {
                        final isLast =
                            entry.key == record.extractedFields.length - 1;
                        final field = entry.value;
                        return Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            border: isLast
                                ? null
                                : const Border(
                                    bottom: BorderSide(
                                      color: AppColors.bg,
                                      width: 1,
                                    ),
                                  ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 130,
                                child: Text(
                                  field.key,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.muted,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  field.value,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.dark,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Integration section
                  _SectionCard(
                    title: 'Інтеграція: ${record.integrationSystem}',
                    icon: Icons.hub_rounded,
                    child: _IntegrationSection(
                      record: record,
                      isRequesting: _isRequesting,
                      requestDone: _requestDone,
                      integrationRef: _integrationRef,
                      onRequest: _sendIntegrationRequest,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // SRM section
                  _SectionCard(
                    title: 'Документ у SRM',
                    icon: Icons.cloud_download_rounded,
                    trailing: _srmDone
                        ? Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.success.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.check_circle_rounded,
                                    size: 11, color: AppColors.success),
                                SizedBox(width: 4),
                                Text(
                                  'Підгружено',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.success,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : null,
                    child: _SrmSection(
                      record: record,
                      isLoading: _isSrmLoading,
                      isDone: _srmDone,
                      srmDocRef: _srmDocUrl,
                      onLoad: _loadFromSrm,
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
    this.trailing,
  });

  final String title;
  final IconData icon;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(
              children: [
                Icon(icon, size: 16, color: AppColors.muted),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.dark,
                  ),
                ),
                if (trailing != null) ...[
                  const Spacer(),
                  trailing!,
                ],
              ],
            ),
          ),
          const SizedBox(height: 4),
          const Divider(color: AppColors.border, height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            child: child,
          ),
        ],
      ),
    );
  }
}

class _IntegrationSection extends StatelessWidget {
  const _IntegrationSection({
    required this.record,
    required this.isRequesting,
    required this.requestDone,
    required this.integrationRef,
    required this.onRequest,
  });

  final DocRecord record;
  final bool isRequesting;
  final bool requestDone;
  final String? integrationRef;
  final VoidCallback onRequest;

  @override
  Widget build(BuildContext context) {
    // Already synced — show external ID
    if (record.status == DocRecordStatus.synced && record.externalId != null) {
      return _SyncedResult(
        integrationSystem: record.integrationSystem,
        externalId: record.externalId!,
      );
    }

    // After successful request
    if (requestDone && integrationRef != null) {
      return _SyncedResult(
        integrationSystem: record.integrationSystem,
        externalId: integrationRef!,
        isJustSynced: true,
      );
    }

    // Pending state — still processing
    if (record.status == DocRecordStatus.pending) {
      return const Padding(
        padding: EdgeInsets.only(top: 12),
        child: Row(
          children: [
            Icon(Icons.hourglass_empty_rounded,
                size: 16, color: AppColors.muted),
            SizedBox(width: 8),
            Text(
              'Документ ще обробляється системою розпізнавання',
              style: TextStyle(fontSize: 12, color: AppColors.muted),
            ),
          ],
        ),
      );
    }

    // Processed — ready to push to integration
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Документ оброблено і готовий до передачі в ${record.integrationSystem}. '
            'Натисніть кнопку щоб надіслати запит та отримати номер запису.',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.muted,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: isRequesting ? null : onRequest,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.brand,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: isRequesting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.send_rounded, size: 18),
              label: Text(
                isRequesting
                    ? 'Надсилання запиту…'
                    : 'Запит до ${record.integrationSystem}',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SrmSection extends StatelessWidget {
  const _SrmSection({
    required this.record,
    required this.isLoading,
    required this.isDone,
    required this.srmDocRef,
    required this.onLoad,
  });

  final DocRecord record;
  final bool isLoading;
  final bool isDone;
  final String? srmDocRef;
  final VoidCallback onLoad;

  @override
  Widget build(BuildContext context) {
    if (isDone && srmDocRef != null) {
      return Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ref row
            Row(
              children: [
                const Text(
                  'Референс SRM:',
                  style: TextStyle(fontSize: 12, color: AppColors.muted),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.bg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    srmDocRef!,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.dark,
                      fontFamily: 'monospace',
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ],
            ),
            // Document preview
            _DocPreviewCard(record: record),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Підгрузити оригінал документу з системи управління закупівлями SRM для звірки з розпізнаними даними.',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.muted,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: isLoading ? null : onLoad,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.brand,
                side: const BorderSide(color: AppColors.brand),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.brand,
                      ),
                    )
                  : const Icon(Icons.cloud_download_rounded, size: 18),
              label: Text(
                isLoading ? 'Підгрузка з SRM…' : 'Підгрузити документ з SRM',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Document preview thumbnail ──────────────────────────────────────────────

class _DocPreviewCard extends StatelessWidget {
  const _DocPreviewCard({required this.record});

  final DocRecord record;

  void _openViewer(BuildContext context) => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => _DocViewerPage(record: record),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 14),
      height: 220,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // ── Document thumbnail ──
            Positioned.fill(
              child: GestureDetector(
                onTap: () => _openViewer(context),
                child: OverflowBox(
                  alignment: Alignment.topCenter,
                  maxHeight: double.infinity,
                  child: Transform.scale(
                    scale: 0.52,
                    alignment: Alignment.topCenter,
                    child: SizedBox(
                      width: double.infinity,
                      child: _MockDocument(record: record),
                    ),
                  ),
                ),
              ),
            ),

            // ── Bottom fade ──
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 56,
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withValues(alpha: 0.0),
                        Colors.white.withValues(alpha: 0.96),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ── Open button — floating top-right ──
            Positioned(
              top: 10,
              right: 10,
              child: GestureDetector(
                onTap: () => _openViewer(context),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.brand,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.brand.withValues(alpha: 0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.open_in_full_rounded,
                    size: 16,
                    color: Colors.white,
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

// ── Full-screen viewer ───────────────────────────────────────────────────────

class _DocViewerPage extends StatelessWidget {
  const _DocViewerPage({required this.record});

  final DocRecord record;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111827),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111827),
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              record.docNumber,
              style: const TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
            ),
            Text(
              record.docType,
              style: TextStyle(
                  fontSize: 11,
                  color: Colors.white.withValues(alpha: 0.55)),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded),
            onPressed: () {},
            tooltip: 'Поділитись',
          ),
        ],
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.4,
          maxScale: 5.0,
          child: Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 24,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: _MockDocument(record: record),
          ),
        ),
      ),
    );
  }
}

// ── Mock document renderer ───────────────────────────────────────────────────

class _MockDocument extends StatelessWidget {
  const _MockDocument({required this.record});

  final DocRecord record;

  @override
  Widget build(BuildContext context) {
    const labelStyle = TextStyle(fontSize: 11, color: Color(0xFF64748B));
    const valueStyle = TextStyle(
        fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF0F172A));
    const headerStyle = TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w900,
        color: Color(0xFF0F172A),
        letterSpacing: -0.5);
    const dividerColor = Color(0xFFE2E8F0);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('ТОВ "ПРОМБУД"',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A))),
                    const SizedBox(height: 2),
                    Text('ЄДРПОУ 12345678',
                        style: labelStyle.copyWith(fontSize: 10)),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  border: Border.all(color: dividerColor),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('ОРИГІНАЛ', style: labelStyle.copyWith(fontSize: 9)),
                    const SizedBox(height: 1),
                    Text(record.integrationSystem,
                        style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF2563EB))),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: dividerColor, height: 1),
          const SizedBox(height: 16),

          // ── Title ──
          Text(record.docNumber, style: headerStyle),
          const SizedBox(height: 4),
          Text(record.docType, style: labelStyle),
          const SizedBox(height: 20),

          // ── Fields table ──
          ...record.extractedFields.entries.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 9),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                        width: 120,
                        child: Text(e.key, style: labelStyle)),
                    Expanded(child: Text(e.value, style: valueStyle)),
                  ],
                ),
              )),

          const SizedBox(height: 12),
          const Divider(color: dividerColor, height: 1),
          const SizedBox(height: 16),

          // ── Signature row ──
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Відпустив', style: labelStyle),
                    const SizedBox(height: 20),
                    Container(height: 1, color: dividerColor),
                    const SizedBox(height: 4),
                    Text(record.uploadedBy,
                        style: labelStyle.copyWith(fontSize: 10)),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Отримав', style: labelStyle),
                    const SizedBox(height: 20),
                    Container(height: 1, color: dividerColor),
                    const SizedBox(height: 4),
                    Text('_______________',
                        style: labelStyle.copyWith(fontSize: 10)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ── Stamp placeholder ──
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    color: const Color(0xFF2563EB).withValues(alpha: 0.25),
                    width: 2),
              ),
              child: Center(
                child: Text(
                  'М.П.',
                  style: TextStyle(
                    fontSize: 11,
                    color: const Color(0xFF2563EB).withValues(alpha: 0.4),
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SyncedResult extends StatelessWidget {
  const _SyncedResult({
    required this.integrationSystem,
    required this.externalId,
    this.isJustSynced = false,
  });

  final String integrationSystem;
  final String externalId;
  final bool isJustSynced;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isJustSynced)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle_rounded,
                      size: 14, color: AppColors.success),
                  SizedBox(width: 6),
                  Text(
                    'Успішно синхронізовано',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
            ),
          Row(
            children: [
              const Text(
                'Система:',
                style: TextStyle(fontSize: 12, color: AppColors.muted),
              ),
              const SizedBox(width: 8),
              Text(
                integrationSystem,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.dark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text(
                'Номер запису:',
                style: TextStyle(fontSize: 12, color: AppColors.muted),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.bg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  externalId,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.dark,
                    fontFamily: 'monospace',
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
