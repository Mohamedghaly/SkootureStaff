import 'dart:convert';

import 'package:eschool_saas_staff/utils/appLanguages.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

abstract class AppTranslation {
  static Map<String, Map<String, String>> translationsKeys = Map.fromEntries(
      appLanguages.map((appLanguage) => appLanguage.languageCode).toList().map(
          (languageCode) =>
              MapEntry(languageCode, Map<String, String>.from({}))));

  /// Codes whose `assets/languages/<code>.json` was actually found and parsed
  /// at startup. A build may ship only `en.json`, so this is what decides
  /// which languages remain selectable when the API is unreachable — see
  /// [AppLocalizationCubit].
  static final Set<String> bundledLanguageCodes = {};

  static Future loadJsons() async {
    for (var languageCode in translationsKeys.keys) {
      try {
        final String jsonStringValues =
            await rootBundle.loadString('assets/languages/$languageCode.json');
        //value from rootbundle will be encoded string
        Map<String, dynamic> mappedJson = json.decode(jsonStringValues);

        translationsKeys[languageCode] = mappedJson.cast<String, String>();
        if (translationsKeys[languageCode]!.isNotEmpty) {
          bundledLanguageCodes.add(languageCode);
        }
      } catch (e) {
        // A missing/broken language file must not block app start; keys of
        // this language fall back to the API labels or the fallback locale.
        if (kDebugMode) {
          debugPrint(
              "Localization: bundled '$languageCode.json' unusable ($e)");
        }
      }
    }

    if (kDebugMode && !bundledLanguageCodes.contains(defaultLanguageCode)) {
      debugPrint(
          "Localization: WARNING assets/languages/$defaultLanguageCode.json is missing or invalid — with no API labels every key renders as its raw key.");
    }
  }

  /// Language used as the last-resort source for keys the active language does
  /// not provide (GetX's `fallbackLocale`).
  ///
  /// This has to be a language that actually ships with the build, otherwise
  /// missing keys would render as their raw key. [defaultLanguageCode] is
  /// preferred so the app falls back to its own default language; when that
  /// default lives only on the panel and has no bundled json, the first
  /// bundled language is used instead.
  static String get fallbackLanguageCode {
    if (bundledLanguageCodes.contains(defaultLanguageCode)) {
      return defaultLanguageCode;
    }
    return bundledLanguageCodes.isEmpty
        ? defaultLanguageCode
        : bundledLanguageCodes.first;
  }

  static bool hasTranslationsFor(String languageCode) =>
      (translationsKeys[_normalizeLanguageCode(languageCode)] ?? {})
          .isNotEmpty;

  /// Overlays labels fetched from the panel on top of the bundled ones and
  /// keeps GetX's live translations in sync, so `.tr` picks them up whether
  /// this runs before or after `GetMaterialApp` is built. Bundled values stay
  /// as fallback for keys the API does not provide.
  ///
  /// Returns whether anything changed, so callers can skip rebuilding the app
  /// when the applied labels were already up to date.
  static bool overlayRemoteLabels(
      Map<String, Map<String, String>> remoteLabels) {
    var changed = false;
    final Map<String, Map<String, String>> changedLabels = {};

    remoteLabels.forEach((languageCode, labels) {
      final normalizedCode = _normalizeLanguageCode(languageCode);
      final translations =
          translationsKeys.putIfAbsent(normalizedCode, () => {});
      labels.forEach((key, value) {
        if (translations[key] != value) {
          translations[key] = value;
          changed = true;
          (changedLabels[normalizedCode] ??= {})[key] = value;
        }
      });
    });

    if (changed) {
      Get.appendTranslations(changedLabels);
    }
    return changed;
  }

  /// GetX keys locale translations as `language_COUNTRY` while panel language
  /// codes may use `language-COUNTRY` (e.g. zh-CN).
  static String _normalizeLanguageCode(String languageCode) =>
      languageCode.replaceAll("-", "_");
}
