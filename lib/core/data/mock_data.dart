import 'package:rekognita_app/features/company_context/domain/entities/company.dart';

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
