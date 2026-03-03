import 'package:rekognita_app/core/constants/app_colors.dart';
import 'package:rekognita_app/features/company_context/domain/entities/company.dart';
import 'package:rekognita_app/features/dashboard/domain/entities/dashboard_models.dart';
import 'package:rekognita_app/features/document_types/domain/entities/document_type.dart';
import 'package:rekognita_app/features/integrations/domain/entities/integration.dart';
import 'package:rekognita_app/features/team/domain/entities/employee.dart';
import 'package:rekognita_app/features/templates/domain/entities/parsing_template.dart';

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
      'Назва товару',
      'Артикул',
      'Кількість',
      'Ціна',
      'Сума',
      'Дата',
      'Постачальник',
    ],
  ),
  ParsingTemplate(
    id: 2,
    docType: 'Медичні довідки',
    fields: ['ПІБ', 'Дата народження', 'Діагноз', 'Лікар', 'Дата видачі'],
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
