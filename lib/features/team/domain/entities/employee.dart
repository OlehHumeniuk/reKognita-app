class Employee {
  const Employee({
    required this.id,
    required this.name,
    required this.role,
    required this.dept,
    required this.isActive,
    required this.docs,
  });

  final int id;
  final String name;
  final String role;
  final String dept;
  final bool isActive;
  final List<String> docs;
}
