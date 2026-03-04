import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rekognita_app/core/constants/app_colors.dart';
import 'package:rekognita_app/features/dashboard/domain/entities/doc_record.dart';
import 'package:rekognita_app/features/dashboard/presentation/pages/doc_record_page.dart';

class DocProcessListPage extends StatefulWidget {
  const DocProcessListPage({required this.records, super.key});

  final List<DocRecord> records;

  @override
  State<DocProcessListPage> createState() => _DocProcessListPageState();
}

class _DocProcessListPageState extends State<DocProcessListPage> {
  final _searchController = TextEditingController();
  String _query = '';
  DocRecordStatus? _filterStatus;
  String? _filterDocType;
  Timer? _debounceTimer;
  late final Map<String, String> _searchIndex;

  @override
  void initState() {
    super.initState();
    _searchIndex = {
      for (final r in widget.records)
        r.id: [
          r.docNumber,
          r.uploadedBy,
          r.docType,
          r.integrationSystem,
          r.externalId ?? '',
          ...r.extractedFields.values,
        ].join(' ').toLowerCase(),
    };
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _query = value.toLowerCase().trim());
    });
  }

  List<DocRecord> get _filtered {
    return widget.records.where((r) {
      final matchesQuery = _query.isEmpty || (_searchIndex[r.id] ?? '').contains(_query);
      final matchesStatus = _filterStatus == null || r.status == _filterStatus;
      final matchesType = _filterDocType == null || r.docType == _filterDocType;
      return matchesQuery && matchesStatus && matchesType;
    }).toList();
  }

  List<String> get _docTypes =>
      widget.records.map((r) => r.docType).toSet().toList()..sort();

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.dark,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Обробка документів',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Container(
            color: AppColors.dark,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Пошук за документом, полями, системою…',
                hintStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4),
                  fontSize: 14,
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: Colors.white.withValues(alpha: 0.5),
                  size: 20,
                ),
                suffixIcon: _query.isNotEmpty
                    ? GestureDetector(
                        onTap: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                        child: Icon(
                          Icons.close_rounded,
                          color: Colors.white.withValues(alpha: 0.5),
                          size: 18,
                        ),
                      )
                    : null,
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.08),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // ── Status filter chips
          Container(
            color: AppColors.white,
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _FilterChip(
                    label: 'Всі',
                    isActive: _filterStatus == null,
                    onTap: () => setState(() => _filterStatus = null),
                  ),
                  const SizedBox(width: 8),
                  ...DocRecordStatus.values.map((status) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _FilterChip(
                          label: status.label,
                          color: status.color,
                          isActive: _filterStatus == status,
                          onTap: () => setState(() {
                            _filterStatus = _filterStatus == status ? null : status;
                          }),
                        ),
                      )),
                ],
              ),
            ),
          ),

          // ── Doc-type filter chips (shown only when >1 type present)
          if (_docTypes.length > 1)
            Container(
              color: AppColors.white,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _FilterChip(
                      label: 'Всі типи',
                      isActive: _filterDocType == null,
                      onTap: () => setState(() => _filterDocType = null),
                    ),
                    const SizedBox(width: 8),
                    ..._docTypes.map((type) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _FilterChip(
                            label: type,
                            isActive: _filterDocType == type,
                            onTap: () => setState(() {
                              _filterDocType = _filterDocType == type ? null : type;
                            }),
                          ),
                        )),
                  ],
                ),
              ),
            ),

          const Divider(height: 1, color: AppColors.border),

          // ── Results count
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
            child: Row(
              children: [
                Text(
                  '${filtered.length} записів',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.muted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // ── List
          Expanded(
            child: filtered.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.search_off_rounded, size: 48, color: AppColors.border),
                        SizedBox(height: 12),
                        Text(
                          'Нічого не знайдено',
                          style: TextStyle(color: AppColors.muted, fontSize: 14),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) =>
                        _DocRecordListItem(record: filtered[index]),
                  ),
          ),
        ],
      ),
    );
  }
}

// ── Filter chip ──────────────────────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isActive,
    required this.onTap,
    this.color,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final activeColor = color ?? AppColors.brand;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? activeColor.withValues(alpha: 0.12) : AppColors.bg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? activeColor : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isActive ? activeColor : AppColors.muted,
          ),
        ),
      ),
    );
  }
}

// ── Full card list item ──────────────────────────────────────────────────────

class _DocRecordListItem extends StatelessWidget {
  const _DocRecordListItem({required this.record});

  final DocRecord record;

  @override
  Widget build(BuildContext context) {
    final status = record.status;
    final color = record.typeColor;

    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => DocRecordPage(record: record)),
      ),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            // Type icon
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Text(record.typeIcon, style: const TextStyle(fontSize: 20)),
            ),
            const SizedBox(width: 12),

            // Doc info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    record.docNumber,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.dark,
                      height: 1.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${record.uploadedBy} · ${record.timeAgo}',
                    style: const TextStyle(fontSize: 12, color: AppColors.muted),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),

            // Status badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: status.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(status.icon, size: 11, color: status.color),
                  const SizedBox(width: 4),
                  Text(
                    status.label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: status.color,
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
