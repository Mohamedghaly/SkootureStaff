import 'package:eschool_saas_staff/data/models/appLanguage.dart';
import 'package:eschool_saas_staff/utils/api.dart';
import 'package:eschool_saas_staff/utils/hiveBoxKeys.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Panel-managed localization: the list of languages enabled for this app and
/// the label values of each language. Fetched labels are cached in Hive and
/// overlaid on top of the bundled language files, which remain the offline
/// fallback.
class LocalizationRepository {
  /// App type expected by the labels API ([student, staff, web]).
  static const String _appType = "staff";

  Future<List<AppLanguage>> fetchAppLanguages() async {
    try {
      final result = await Api.get(url: Api.getLanguages, useAuthToken: false);

      return ((result['data'] ?? []) as List)
          .map((language) =>
              AppLanguage.fromJson(Map<String, dynamic>.from(language ?? {})))
          .where((language) => language.languageCode.isNotEmpty)
          .toList();
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<Map<String, String>> fetchLabels(
      {required String languageCode}) async {
    try {
      final result = await Api.post(
        url: Api.getLanguageLabels,
        body: {
          "language_code": languageCode,
          "type": _appType,
        },
        useAuthToken: false,
      );

      return _extractLabels(result['data']);
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  /// `set-languages` returns the language record itself; the labels live in
  /// its `file_name` key as a key-value map, which is empty when no file has
  /// been uploaded on the panel for this app type. Null/empty values are
  /// dropped so the bundled value keeps being shown for those keys.
  Map<String, String> _extractLabels(dynamic data) {
    if (data is! Map) {
      return {};
    }
    final dynamic source = data['file_name'] is Map
        ? data['file_name']
        : data['labels'] is Map
            ? data['labels']
            : data['translations'];
    if (source is! Map) {
      return {};
    }

    final Map<String, String> labels = {};
    source.forEach((key, value) {
      if (value == null) {
        return;
      }
      final label = value.toString().trim();
      if (label.isNotEmpty) {
        labels[key.toString()] = label;
      }
    });
    return labels;
  }

  Future<void> cacheAppLanguages(List<AppLanguage> languages) async {
    await Hive.box(localizationBoxKey).put(cachedAppLanguagesKey,
        languages.map((language) => language.toJson()).toList());
  }

  List<AppLanguage> getCachedAppLanguages() {
    return ((Hive.box(localizationBoxKey).get(cachedAppLanguagesKey) ?? [])
            as List)
        .map((language) => AppLanguage.fromJson(Map.from(language ?? {})))
        .where((language) => language.languageCode.isNotEmpty)
        .toList();
  }

  Future<void> cacheLabels(
      {required String languageCode,
      required Map<String, String> labels}) async {
    await Hive.box(localizationBoxKey)
        .put("$cachedLabelsKeyPrefix$languageCode", labels);
  }

  /// Labels of every language cached so far, keyed by language code.
  Map<String, Map<String, String>> getAllCachedLabels() {
    final box = Hive.box(localizationBoxKey);
    final Map<String, Map<String, String>> cachedLabels = {};
    for (final key in box.keys) {
      final keyString = key.toString();
      if (!keyString.startsWith(cachedLabelsKeyPrefix)) {
        continue;
      }
      cachedLabels[keyString.substring(cachedLabelsKeyPrefix.length)] =
          Map<String, String>.from(box.get(key) ?? {});
    }
    return cachedLabels;
  }
}
