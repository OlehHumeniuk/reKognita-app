class Employee {
  const Employee({
    required this.id,
    required this.name,
    required this.role,
    required this.dept,
    required this.isActive,
    required this.isBlocked,
    required this.docs,
    this.lastSeenAt,
    this.inviteCode,
  });

  final int id;
  final String name;
  final String role;
  final String dept;
  final bool isActive;
  final bool isBlocked;
  final DateTime? lastSeenAt;
  final List<String> docs;
  final String? inviteCode;

  bool get isOnline {
    if (lastSeenAt == null) return false;
    return DateTime.now().toUtc().difference(lastSeenAt!).inMinutes < 5;
  }
}
