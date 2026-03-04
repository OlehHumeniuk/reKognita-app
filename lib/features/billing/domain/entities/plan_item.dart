class PlanItem {
  const PlanItem({
    required this.id,
    required this.name,
    required this.price,
    this.pages,
    required this.isTrial,
    required this.features,
    required this.hint,
    required this.recommended,
  });

  final String id;
  final String name;
  final int price;
  final int? pages; // null = unlimited
  final bool isTrial;
  final List<String> features;
  final String hint;
  final bool recommended;

  factory PlanItem.fromJson(Map<String, dynamic> j) => PlanItem(
        id: j['id'] as String,
        name: j['name'] as String,
        price: j['price'] as int,
        pages: j['pages'] as int?,
        isTrial: j['is_trial'] as bool,
        features: (j['features'] as List).cast<String>(),
        hint: j['hint'] as String,
        recommended: j['recommended'] as bool,
      );
}
