enum CompanyPlan { cloud, selfHosted }

class Company {
  const Company({
    required this.id,
    required this.name,
    required this.plan,
    required this.pages,
    required this.limit,
  });

  final int id;
  final String name;
  final CompanyPlan plan;
  final int pages;
  final int? limit;

  factory Company.fromJson(Map<String, dynamic> json) {
    final planStr = json['plan'] as String? ?? '';
    return Company(
      id: json['id'] as int,
      name: json['name'] as String,
      plan: planStr == 'enterprise' ? CompanyPlan.selfHosted : CompanyPlan.cloud,
      pages: json['pages'] as int? ?? 0,
      limit: json['limit'] as int?,
    );
  }
}
