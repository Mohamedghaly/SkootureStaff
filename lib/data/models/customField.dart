class CustomField {
  final int? id; // Custom field value record ID
  final int? formFieldId; // Form field definition ID
  final String? name;
  final String? key;
  final String? type; // text, number, textarea, dropdown, radio, checkbox, file
  final bool? isRequired;
  final dynamic defaultValue; // Can be String, List, or null
  final String? value;
  final String? userType;
  final dynamic options;
  final int? rank;

  CustomField({
    this.id,
    this.formFieldId,
    this.name,
    this.key,
    this.type,
    this.isRequired,
    this.defaultValue,
    this.value,
    this.userType,
    this.options,
    this.rank,
  });

  CustomField copyWith({
    int? id,
    int? formFieldId,
    String? name,
    String? key,
    String? type,
    bool? isRequired,
    dynamic defaultValue,
    String? value,
    String? userType,
    dynamic options,
    int? rank,
  }) {
    return CustomField(
      id: id ?? this.id,
      formFieldId: formFieldId ?? this.formFieldId,
      name: name ?? this.name,
      key: key ?? this.key,
      type: type ?? this.type,
      isRequired: isRequired ?? this.isRequired,
      defaultValue: defaultValue ?? this.defaultValue,
      value: value ?? this.value,
      userType: userType ?? this.userType,
      options: options ?? this.options,
      rank: rank ?? this.rank,
    );
  }

  factory CustomField.fromJson(Map<String, dynamic> json) {
    return CustomField(
      id: json['id'] as int?,
      formFieldId: json['form_field_id'] as int?,
      name: json['name'] as String?,
      key: json['key'] as String?,
      type: json['type'] as String?,
      isRequired: json['is_required'] as bool?,
      defaultValue: json['default_value'],
      value: json['value'] as String?,
      userType: json['user_type'] as String?,
      options: json['options'],
      rank: json['rank'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'form_field_id': formFieldId,
      'name': name,
      'key': key,
      'type': type,
      'is_required': isRequired,
      'default_value': defaultValue,
      'value': value,
      'user_type': userType,
      'options': options,
      'rank': rank,
    };
  }

  // Helper method to get dropdown/radio options as list
  List<String> getOptionsAsList() {
    if (defaultValue is List) {
      return (defaultValue as List).map((e) => e.toString()).toList();
    }
    return [];
  }

  // Check if field type is one of the supported types
  bool isValidType() {
    const validTypes = [
      'text',
      'number',
      'textarea',
      'dropdown',
      'radio',
      'checkbox',
      'file'
    ];
    return validTypes.contains(type?.toLowerCase());
  }
}
