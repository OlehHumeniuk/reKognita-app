import 'package:rekognita_app/core/constants/app_colors.dart';
import 'package:rekognita_app/features/company_context/domain/entities/company.dart';
import 'package:rekognita_app/features/dashboard/domain/entities/dashboard_models.dart';
import 'package:rekognita_app/features/dashboard/domain/entities/doc_record.dart';
import 'package:rekognita_app/features/document_types/domain/entities/document_type.dart';
import 'package:rekognita_app/features/integrations/domain/entities/integration.dart';
import 'package:rekognita_app/features/team/domain/entities/employee.dart';
import 'package:rekognita_app/features/templates/domain/entities/parsing_template.dart';
import 'package:rekognita_app/features/templates/domain/entities/template_field.dart';

const seedCompanies = [
  Company(
    id: 1,
    name: 'Промбуд ТОВ',
    plan: CompanyPlan.cloud,
    pages: 1240,
    limit: 2000,
  ),
  Company(
    id: 2,
    name: 'МедЦентр Плюс',
    plan: CompanyPlan.selfHosted,
    pages: 834,
    limit: null,
  ),
  Company(
    id: 3,
    name: 'Логістик Груп',
    plan: CompanyPlan.cloud,
    pages: 310,
    limit: 500,
  ),
];

const seedStats = [
  DashboardStat(
    value: '247',
    label: 'Документів сьогодні',
    delta: '+18% до вчора',
  ),
  DashboardStat(value: '23', label: 'Активних співробітників'),
  DashboardStat(value: '5', label: 'Типів документів'),
  DashboardStat(value: '99.1%', label: 'Точність розпізнавання'),
];

const seedActivity = [
  ActivityItem(
    name: 'Олексій Коваль',
    action: 'завантажив Накладну №1247',
    time: '2 хв тому',
    type: 'Накладні',
  ),
  ActivityItem(
    name: 'Марина Петрова',
    action: 'завантажила Рахунок-фактуру',
    time: '14 хв тому',
    type: 'Рахунки',
  ),
  ActivityItem(
    name: 'Тетяна Мороз',
    action: 'завантажила Накладну №1246',
    time: '31 хв тому',
    type: 'Накладні',
  ),
  ActivityItem(
    name: 'Іван Сидоренко',
    action: 'завантажив Медичну довідку',
    time: '1 год тому',
    type: 'Медичні',
  ),
];

const seedDistribution = [
  DistributionItem(name: 'Накладні', percent: 52, color: AppColors.brandLight),
  DistributionItem(name: 'Рахунки', percent: 22, color: AppColors.warning),
  DistributionItem(name: 'Договори', percent: 14, color: AppColors.mid),
  DistributionItem(name: 'Медичні', percent: 8, color: AppColors.success),
  DistributionItem(name: 'Паспорти', percent: 4, color: AppColors.danger),
];

const seedEmployees = [
  Employee(
    id: 1,
    name: 'Олексій Коваль',
    role: 'Комірник',
    dept: 'Склад',
    isActive: true,
    docs: ['Накладні', 'Акти'],
  ),
  Employee(
    id: 2,
    name: 'Марина Петрова',
    role: 'Бухгалтер',
    dept: 'Бухгалтерія',
    isActive: true,
    docs: ['Рахунки', 'Договори'],
  ),
  Employee(
    id: 3,
    name: 'Іван Сидоренко',
    role: 'Медпрацівник',
    dept: 'HR/Медицина',
    isActive: false,
    docs: ['Медичні довідки'],
  ),
  Employee(
    id: 4,
    name: 'Тетяна Мороз',
    role: 'Логіст',
    dept: 'Логістика',
    isActive: true,
    docs: ['Накладні'],
  ),
];

const seedDocumentTypes = [
  DocumentType(
    id: 1,
    name: 'Накладні',
    icon: '📦',
    integration: '1С/БАС',
    fields: 7,
    workers: 12,
    color: AppColors.brandLight,
  ),
  DocumentType(
    id: 2,
    name: 'Медичні довідки',
    icon: '🏥',
    integration: 'MedCRM',
    fields: 5,
    workers: 3,
    color: AppColors.success,
  ),
  DocumentType(
    id: 3,
    name: 'Договори',
    icon: '📋',
    integration: 'DocFlow',
    fields: 9,
    workers: 6,
    color: AppColors.mid,
  ),
  DocumentType(
    id: 4,
    name: 'Рахунки-фактури',
    icon: '💰',
    integration: '1С/БАС',
    fields: 6,
    workers: 8,
    color: AppColors.warning,
  ),
  DocumentType(
    id: 5,
    name: 'Паспорти',
    icon: '🪪',
    integration: 'HR CRM',
    fields: 4,
    workers: 2,
    color: AppColors.danger,
  ),
];

const seedTemplates = [
  ParsingTemplate(
    id: 1,
    docType: 'Накладні',
    fields: [
      TemplateField(name: 'Назва товару', type: FieldType.text),
      TemplateField(name: 'Артикул', type: FieldType.text),
      TemplateField(
        name: 'Позиції',
        type: FieldType.table,
        tableColumns: ['Назва', 'Кількість', 'Ціна', 'Сума'],
      ),
      TemplateField(
        name: 'Підсумок',
        type: FieldType.formula,
        signatureLabel: 'М.П.',
      ),
      TemplateField(name: 'Дата', type: FieldType.text),
      TemplateField(name: 'Постачальник', type: FieldType.text),
    ],
  ),
  ParsingTemplate(
    id: 2,
    docType: 'Медичні довідки',
    fields: [
      TemplateField(name: 'ПІБ', type: FieldType.text),
      TemplateField(name: 'Дата народження', type: FieldType.text),
      TemplateField(name: 'Діагноз', type: FieldType.text),
      TemplateField(name: 'Лікар', type: FieldType.text),
      TemplateField(name: 'Дата видачі', type: FieldType.text),
      TemplateField(
        name: 'Печатка',
        type: FieldType.image,
        signatureLabel: 'Підпис лікаря',
      ),
    ],
  ),
];

final seedDocRecords = [
  DocRecord(
    id: 'dr-001',
    docNumber: 'Накладна №1247',
    docType: 'Накладні',
    typeIcon: '📦',
    typeColor: AppColors.brandLight,
    uploadedBy: 'Олексій Коваль',
    uploadedAt: DateTime.now().subtract(const Duration(minutes: 2)),
    status: DocRecordStatus.synced,
    externalId: 'НАК-2024-1247',
    integrationSystem: '1С/БАС',
    extractedFields: {
      'Постачальник': 'ТОВ "Промбуд"',
      'Дата': '03.03.2026',
      'Сума': '45 200,00 грн',
      'ПДВ': '7 533,33 грн',
      'Товарів': '12 позицій',
      'Артикул': 'ПБ-445-А',
      'Відповідальний': 'Олексій Коваль',
    },
  ),
  DocRecord(
    id: 'dr-002',
    docNumber: 'Рахунок-фактура №RF-2834',
    docType: 'Рахунки',
    typeIcon: '💰',
    typeColor: AppColors.warning,
    uploadedBy: 'Марина Петрова',
    uploadedAt: DateTime.now().subtract(const Duration(minutes: 14)),
    status: DocRecordStatus.processed,
    integrationSystem: '1С/БАС',
    extractedFields: {
      'Постачальник': 'ФОП Іваненко',
      'Дата': '03.03.2026',
      'Сума': '12 800,00 грн',
      'ПДВ': '2 133,33 грн',
      'Послуга': 'Транспортні послуги',
      'Договір': 'ДГ-2024-18',
    },
  ),
  DocRecord(
    id: 'dr-003',
    docNumber: 'Накладна №1246',
    docType: 'Накладні',
    typeIcon: '📦',
    typeColor: AppColors.brandLight,
    uploadedBy: 'Тетяна Мороз',
    uploadedAt: DateTime.now().subtract(const Duration(minutes: 31)),
    status: DocRecordStatus.synced,
    externalId: 'НАК-2024-1246',
    integrationSystem: '1С/БАС',
    extractedFields: {
      'Постачальник': 'ТОВ "МеталКонструкція"',
      'Дата': '03.03.2026',
      'Сума': '28 700,00 грн',
      'ПДВ': '4 783,33 грн',
      'Товарів': '7 позицій',
      'Артикул': 'МК-221-Б',
      'Відповідальний': 'Тетяна Мороз',
    },
  ),
  DocRecord(
    id: 'dr-004',
    docNumber: 'Медична довідка №МД-891',
    docType: 'Медичні',
    typeIcon: '🏥',
    typeColor: AppColors.success,
    uploadedBy: 'Іван Сидоренко',
    uploadedAt: DateTime.now().subtract(const Duration(hours: 1)),
    status: DocRecordStatus.pending,
    integrationSystem: 'MedCRM',
    extractedFields: {
      'ПІБ': 'Сидоренко Іван Петрович',
      'Дата народження': '15.06.1985',
      'Діагноз': 'Здоровий',
      'Лікар': 'Ковтун О.В.',
      'Дата видачі': '03.03.2026',
    },
  ),
];

const seedIntegrations = [
  Integration(
    name: '1С/БАС Бухгалтерія',
    status: IntegrationStatus.connected,
    types: ['Накладні', 'Рахунки-фактури'],
    icon: '🏢',
    color: AppColors.warning,
  ),
  Integration(
    name: 'MedCRM',
    status: IntegrationStatus.connected,
    types: ['Медичні довідки'],
    icon: '🏥',
    color: AppColors.success,
  ),
  Integration(
    name: 'DocFlow',
    status: IntegrationStatus.pending,
    types: ['Договори'],
    icon: '📋',
    color: AppColors.mid,
  ),
  Integration(
    name: 'HR Portal',
    status: IntegrationStatus.disconnected,
    types: ['Паспорти'],
    icon: '👥',
    color: AppColors.danger,
  ),
];
