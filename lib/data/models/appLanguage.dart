class AppLanguage {
  final String languageName;
  final String languageCode;

  /// Whether this language lays out right-to-left. Panel languages can use
  /// custom codes (e.g. "002") whose direction Flutter/GetX cannot infer, so
  /// the panel's explicit flag is carried along.
  final bool isRtl;

  /// Flag/icon shown next to the language name in the picker. May be a raster
  /// (jpg/png) or vector (svg) url, or null if the panel has none set.
  final String? imageUrl;

  const AppLanguage({
    required this.languageCode,
    required this.languageName,
    this.isRtl = false,
    this.imageUrl,
  });

  factory AppLanguage.fromJson(Map<String, dynamic> json) {
    final languageCode =
        (json['code'] ?? json['language_code'] ?? json['languageCode'] ?? '')
            .toString()
            .trim();
    final languageName = (json['name'] ??
            json['language'] ??
            json['language_name'] ??
            json['languageName'] ??
            '')
        .toString()
        .trim();
    final imageUrl =
        (json['image'] ?? json['flag'] ?? json['image_url'] ?? '')
            .toString()
            .trim();
    return AppLanguage(
      languageCode: languageCode,
      languageName: languageName.isEmpty ? languageCode : languageName,
      isRtl: _parseIsRtl(json['is_rtl'] ?? json['rtl'] ?? json['isRtl']),
      imageUrl: imageUrl.isEmpty ? null : imageUrl,
    );
  }

  /// The panel sends the flag as 0/1 (get-languages) or bool (set-languages).
  static bool _parseIsRtl(dynamic value) {
    if (value is bool) {
      return value;
    }
    final normalized = value?.toString().toLowerCase();
    return normalized == "1" || normalized == "true";
  }

  Map<String, dynamic> toJson() => {
        "code": languageCode,
        "name": languageName,
        "is_rtl": isRtl ? 1 : 0,
        "image": imageUrl,
      };
}
