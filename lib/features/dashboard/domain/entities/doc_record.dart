import 'package:flutter/material.dart';

const _docTypeColors = <String, Color>{
  'Накладні': Color(0xFF93C5FD),
  'Рахунки': Color(0xFFFBBF24),
  'Договори': Color(0xFF64748B),
  'Медичні довідки': Color(0xFF10B981),
  'Акти': Color(0xFF2563EB),
};

enum DocRecordStatus { pending, processed, synced, error }

extension DocRecordStatusExt on DocRecordStatus {
  String get label => switch (this) {
        DocRecordStatus.pending => 'Обробляється',
        DocRecordStatus.processed => 'Оброблено',
        DocRecordStatus.synced => 'Синхронізовано',
        DocRecordStatus.error => 'Помилка',
      };

  Color get color => switch (this) {
        DocRecordStatus.pending => const Color(0xFFF59E0B),
        DocRecordStatus.processed => const Color(0xFF3B82F6),
        DocRecordStatus.synced => const Color(0xFF10B981),
        DocRecordStatus.error => const Color(0xFFEF4444),
      };

  IconData get icon => switch (this) {
        DocRecordStatus.pending => Icons.hourglass_empty_rounded,
        DocRecordStatus.processed => Icons.check_circle_outline_rounded,
        DocRecordStatus.synced => Icons.cloud_done_rounded,
        DocRecordStatus.error => Icons.error_outline_rounded,
      };
}

class DocRecord {
  const DocRecord({
    required this.id,
    required this.docNumber,
    required this.docType,
    required this.typeIcon,
    required this.typeColor,
    required this.uploadedBy,
    required this.uploadedAt,
    required this.status,
    required this.extractedFields,
    required this.integrationSystem,
    this.externalId,
  });

  final String id;
  final String docNumber;
  final String docType;
  final String typeIcon;
  final Color typeColor;
  final String uploadedBy;
  final DateTime uploadedAt;
  final DocRecordStatus status;
  final String? externalId;
  final Map<String, String> extractedFields;
  final String integrationSystem;

  factory DocRecord.fromJson(Map<String, dynamic> json) {
    final docType = json['docType'] as String? ?? '';
    final statusStr = json['status'] as String? ?? 'processed';
    final status = switch (statusStr) {
      'pending' => DocRecordStatus.pending,
      'synced' => DocRecordStatus.synced,
      'error' => DocRecordStatus.error,
      _ => DocRecordStatus.processed,
    };
    final rawFields = json['extractedFields'] as Map<String, dynamic>? ?? {};
    return DocRecord(
      id: (json['id'] as int).toString(),
      docNumber: json['docNumber'] as String? ?? '',
      docType: docType,
      typeIcon: json['typeIcon'] as String? ?? '📄',
      typeColor: _docTypeColors[docType] ?? const Color(0xFF2563EB),
      uploadedBy: json['employeeName'] as String? ?? '',
      uploadedAt: DateTime.parse(json['createdAt'] as String),
      status: status,
      externalId: json['externalId'] as String?,
      integrationSystem: json['integrationSystem'] as String? ?? '—',
      extractedFields: rawFields.map((k, v) => MapEntry(k, v.toString())),
    );
  }

  String get timeAgo {
    final diff = DateTime.now().difference(uploadedAt);
    if (diff.inMinutes < 1) return 'щойно';
    if (diff.inMinutes < 60) return '${diff.inMinutes} хв тому';
    if (diff.inHours < 24) return '${diff.inHours} год тому';
    return '${diff.inDays} дн тому';
  }
}
