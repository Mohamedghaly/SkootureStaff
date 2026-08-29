import 'package:eschool_saas_staff/data/models/countryCode.dart';
import 'package:eschool_saas_staff/utils/api.dart';

class CountryCodeRepository {
  /// The unfiltered list is small and effectively static, so it is kept for the
  /// rest of the app session: re-opening the picker, or resolving the label of
  /// an already stored code, then costs no network call.
  ///
  /// Search results are never cached — they are a server-side filter over this
  /// very list and go stale as the user types.
  static List<CountryCode>? _cachedCountryCodes;

  Future<List<CountryCode>> getCountryCodes({String search = ""}) async {
    final query = search.trim();

    final cached = _cachedCountryCodes;
    if (query.isEmpty && cached != null) {
      return cached;
    }

    try {
      final result = await Api.get(
        url: Api.getCountryCodes,
        queryParameters: query.isEmpty ? null : {"search": query},
      );

      final countryCodes = CountryCode.listFromJson(result['data']);
      if (query.isEmpty) {
        _cachedCountryCodes = countryCodes;
      }
      return countryCodes;
    } catch (e) {
      throw ApiException(e.toString());
    }
  }
}
