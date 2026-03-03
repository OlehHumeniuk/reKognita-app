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
}
