class Fee {
  final int? id;
  final String? name;

  Fee({
    this.id,
    this.name,
  });

  Fee copyWith({
    int? id,
    String? name,
  }) {
    return Fee(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }

  Fee.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int?,
        name = json['name'] as String?;

  Map<String, dynamic> toJson() => {'id': id, 'name': name};

  @override
  bool operator ==(covariant Fee other) {
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
