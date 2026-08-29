/// A dialling code option served by the `country-codes` API.
///
/// The API returns a `code -> label` map (`{"91": "🇮🇳 +91"}`). The key is what
/// gets stored against the user as `country_code`; the value is a ready-to-show
/// label carrying the country flag, so the app never has to build one itself.
///
/// Codes are not always a bare dial code — the ones shared by several countries
/// carry an area suffix (`1-242` -> `🇧🇸 +1 242`), so they are always treated as
/// opaque strings.
class CountryCode {
  final String code;
  final String label;

  const CountryCode({required this.code, required this.label});

  /// Placeholder for a code whose label hasn't been fetched yet — i.e. the value
  /// stored in the user's profile, shown until the API list arrives.
  factory CountryCode.fromCode(String code) =>
      CountryCode(code: code, label: "");

  /// Text to show in the UI. Falls back to `+<code>` while the label is unknown.
  String get displayLabel =>
      label.isNotEmpty ? label : "+${code.replaceAll('-', ' ')}";

  /// Flag half of the label (`🇮🇳` of `🇮🇳 +91`). Empty while the label is
  /// unknown, so callers must treat it as optional.
  String get flag {
    final separatorIndex = label.indexOf(" ");
    return separatorIndex == -1 ? "" : label.substring(0, separatorIndex);
  }

  /// Dialling half of the label (`+91` of `🇮🇳 +91`, `+1 242` of `🇧🇸 +1 242`).
  String get dialCode {
    final separatorIndex = label.indexOf(" ");
    return separatorIndex == -1
        ? displayLabel
        : label.substring(separatorIndex + 1);
  }

  /// Parses the `data` node of the country codes response.
  ///
  /// It is a `code -> label` map when there are matches and an empty list when
  /// there are none, so anything that isn't a map is read as "no results".
  static List<CountryCode> listFromJson(dynamic data) {
    if (data is! Map) return [];

    return data.entries
        .map((entry) => CountryCode(
              code: entry.key.toString(),
              label: (entry.value ?? "").toString(),
            ))
        .toList();
  }

  /// Two options are the same option when they point at the same code — the
  /// label is only presentation.
  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is CountryCode && other.code == code);

  @override
  int get hashCode => code.hashCode;
}
