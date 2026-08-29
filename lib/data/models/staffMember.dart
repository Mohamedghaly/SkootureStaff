/// Represents a staff member for task assignment.
class StaffMember {
  final int id;
  final String name;
  final String role;
  final String? imageUrl;

  const StaffMember({
    required this.id,
    required this.name,
    required this.role,
    this.imageUrl,
  });

  /// Creates a [StaffMember] from the `users-role-wise` API
  /// response JSON.
  ///
  /// Expected fields: `id`, `full_name`, `image`, `role`.
  factory StaffMember.fromJson(Map<String, dynamic> json) {
    return StaffMember(
      id: json['id'] as int,
      name: (json['full_name'] as String?) ?? '',
      role: (json['role'] as String?) ?? '',
      imageUrl: json['image'] as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StaffMember &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
