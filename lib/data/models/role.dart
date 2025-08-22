class Role {
  final int? id;
  final String? name;
  final String? guardName;
  final int? schoolId;
  final int? customRole;
  final int? editable;
  final String? createdAt;
  final String? updatedAt;

  Role({
    this.id,
    this.name,
    this.guardName,
    this.schoolId,
    this.customRole,
    this.editable,
    this.createdAt,
    this.updatedAt,
  });

  Role copyWith({
    int? id,
    String? name,
    String? guardName,
    int? schoolId,
    int? customRole,
    int? editable,
    String? createdAt,
    String? updatedAt,
  }) {
    return Role(
      id: id ?? this.id,
      name: name ?? this.name,
      guardName: guardName ?? this.guardName,
      schoolId: schoolId ?? this.schoolId,
      customRole: customRole ?? this.customRole,
      editable: editable ?? this.editable,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Role.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int?,
        name = json['name'] as String?,
        guardName = json['guard_name'] as String?,
        schoolId = json['school_id'] as int?,
        customRole = json['custom_role'] as int?,
        editable = json['editable'] as int?,
        createdAt = json['created_at'] as String?,
        updatedAt = json['updated_at'] as String?;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'guard_name': guardName,
        'school_id': schoolId,
        'custom_role': customRole,
        'editable': editable,
        'created_at': createdAt,
        'updated_at': updatedAt
      };
}
