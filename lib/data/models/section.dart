class Section {
  final int? id;
  final String? name;
  final int? schoolId;
  final String? deletedAt;

  Section({
    this.id,
    this.name,
    this.schoolId,
    this.deletedAt,
  });

  Section copyWith({
    int? id,
    String? name,
    int? schoolId,
    String? deletedAt,
  }) {
    return Section(
      id: id ?? this.id,
      name: name ?? this.name,
      schoolId: schoolId ?? this.schoolId,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  Section.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int?,
        name = json['name'] as String?,
        schoolId = json['school_id'] as int?,
        deletedAt = json['deleted_at'] as String?;

  Map<String, dynamic> toJson() =>
      {'id': id, 'name': name, 'school_id': schoolId, 'deleted_at': deletedAt};
}
