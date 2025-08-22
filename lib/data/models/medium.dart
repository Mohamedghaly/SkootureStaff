class Medium {
  final int? id;
  final String? name;
  final int? schoolId;
  final String? deletedAt;

  Medium({
    this.id,
    this.name,
    this.schoolId,
    this.deletedAt,
  });

  Medium copyWith({
    int? id,
    String? name,
    int? schoolId,
    String? deletedAt,
  }) {
    return Medium(
      id: id ?? this.id,
      name: name ?? this.name,
      schoolId: schoolId ?? this.schoolId,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  Medium.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int?,
        name = json['name'] as String?,
        schoolId = json['school_id'] as int?,
        deletedAt = json['deleted_at'] as String?;

  Map<String, dynamic> toJson() =>
      {'id': id, 'name': name, 'school_id': schoolId, 'deleted_at': deletedAt};

  @override
  bool operator ==(covariant Medium other) {
    return other.id == id;
  }

  @override
  int get hashCode {
    return id.hashCode;
  }

  @override
  String toString() {
    return (name ?? "");
  }
}
