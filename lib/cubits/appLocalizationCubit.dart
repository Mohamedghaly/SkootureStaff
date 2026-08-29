import 'package:eschool_saas_staff/app/appTranslation.dart';
import 'package:eschool_saas_staff/data/models/appLanguage.dart';
import 'package:eschool_saas_staff/data/repositories/localizationRepository.dart';
import 'package:eschool_saas_staff/data/repositories/settingsRepository.dart';
import 'package:eschool_saas_staff/utils/appLanguages.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class AppLocalizationState {
  final Locale language;

  /// Languages enabled on the panel; falls back to the bundled [appLanguages]
  /// list until the panel list has been fetched at least once.
  final List<AppLanguage> availableLanguages;

  /// True while the labels of a not-yet-cached language are being fetched
  /// during a language switch.
  final bool languageChangeInProgress;

  AppLocalizationState({
    required this.language,
    required this.availableLanguages,
    this.languageChangeInProgress = false,
  });
}

class AppLocalizationCubit extends Cubit<AppLocalizationState> {
  final SettingsRepository _settingsRepository;
  final LocalizationRepository _localizationRepository =
      LocalizationRepository();

  AppLocalizationCubit(this._settingsRepository)
    : super(
        AppLocalizationState(
          language: Utils.getLocaleFromLanguageCode(
            _settingsRepository.getCurrentLanguageCode(),
          ),
          availableLanguages: _initiallyAvailableLanguages(
            _settingsRepository.getCurrentLanguageCode(),
          ),
        ),
      );

  /// Cached panel languages when available, bundled list otherwise.
  static List<AppLanguage> _initiallyAvailableLanguages(String languageCode) {
    final cachedLanguages = LocalizationRepository().getCachedAppLanguages();
    return _withLanguage(
      cachedLanguages.isEmpty ? _bundledLanguages() : cachedLanguages,
      languageCode,
    );
  }

  /// Offline fallback list: only the languages whose json file is actually
  /// bundled with this build. A build that ships a single `en.json` must not
  /// offer the other entries of [appLanguages] while the API is unreachable,
  /// because picking one of them cannot produce any labels.
  static List<AppLanguage> _bundledLanguages() {
    final bundled = appLanguages
        .where(
          (language) => AppTranslation.bundledLanguageCodes.contains(
            language.languageCode,
          ),
        )
        .toList();
    if (bundled.isNotEmpty) {
      return bundled;
    }

    // Not even the default file parsed: still offer the default language so
    // the picker is never empty and the app stays resettable.
    final defaultLanguage = appLanguages
        .where((language) => language.languageCode == defaultLanguageCode)
        .toList();
    return defaultLanguage.isEmpty
        ? const [
            // Default not listed in [appLanguages] either: show the raw code,
            // the same fallback AppLanguage.fromJson uses for unnamed panel
            // languages.
            AppLanguage(
              languageCode: defaultLanguageCode,
              languageName: defaultLanguageCode,
            ),
          ]
        : defaultLanguage;
  }

  /// Keeps [languageCode] present in the picker list. The panel may stop
  /// offering a language the user had already selected (or never offer the
  /// bundled default at all), which would otherwise leave the picker with no
  /// row selected and no way back.
  static List<AppLanguage> _withLanguage(
    List<AppLanguage> languages,
    String languageCode,
  ) {
    if (languages.any((language) => language.languageCode == languageCode)) {
      return languages;
    }
    // Only re-add a language the app can actually render. Resurrecting one
    // with no labels left (its bundled json was dropped from the build, and
    // the panel no longer offers it) would show its name while every string
    // renders in English, and would suppress the reset below by making the
    // language look like it is still on offer.
    if (!AppTranslation.hasTranslationsFor(languageCode)) {
      return languages;
    }
    for (final language in appLanguages) {
      if (language.languageCode == languageCode) {
        return [...languages, language];
      }
    }
    return languages;
  }

  /// Raw code of the current language (e.g. "zh-CN"), unlike
  /// [Locale.languageCode] which drops the country part.
  String get currentLanguageCode =>
      _settingsRepository.getCurrentLanguageCode();

  /// Locale GetX falls back to for keys the active language does not provide,
  /// passed to [GetMaterialApp]. Follows [defaultLanguageCode] as long as that
  /// language is bundled — see [AppTranslation.fallbackLanguageCode].
  Locale get fallbackLocale =>
      Utils.getLocaleFromLanguageCode(AppTranslation.fallbackLanguageCode);

  /// Layout direction of the current language, passed to [GetMaterialApp].
  ///
  /// GetX only knows a fixed set of RTL language codes, so panel languages
  /// with custom codes (e.g. "002") rely on the panel's `is_rtl` flag; the
  /// union keeps real RTL codes (ar/ur) working even without that flag.
  TextDirection get textDirection {
    final code = currentLanguageCode;
    final panelSaysRtl = state.availableLanguages.any(
      (language) => language.languageCode == code && language.isRtl,
    );
    return panelSaysRtl || rtlLanguages.contains(state.language.languageCode)
        ? TextDirection.rtl
        : TextDirection.ltr;
  }

  /// Refreshes the panel languages and the labels of the current language in
  /// the background. Failures are silent: the bundled language files and any
  /// previously cached labels keep the app fully working (e.g. offline).
  Future<void> syncRemoteLocalization() async {
    final directionBeforeSync = textDirection;
    try {
      final languages = await _localizationRepository.fetchAppLanguages();
      if (kDebugMode) {
        debugPrint(
          "Localization: ${languages.length} active panel languages: ${languages.map((language) => language.languageCode).toList()}",
        );
      }
      if (languages.isNotEmpty) {
        await _localizationRepository.cacheAppLanguages(languages);
        emit(
          AppLocalizationState(
            language: state.language,
            availableLanguages: _withLanguage(languages, currentLanguageCode),
            languageChangeInProgress: state.languageChangeInProgress,
          ),
        );
      }
    } catch (e) {
      // Keep cached/bundled language list.
      if (kDebugMode) {
        debugPrint("Localization: language list sync failed: $e");
      }
    }

    await _refreshLabels(currentLanguageCode);
    await _resetToDefaultLanguageIfUnusable();

    // The refreshed list may flip the current language's rtl flag, and a reset
    // changes the language outright.
    if (textDirection != directionBeforeSync) {
      Get.forceAppUpdate();
    }
  }

  /// Last-resort fallback to a language the app can actually render.
  ///
  /// Reached when the current language has no labels at all — no bundled json,
  /// nothing cached, and nothing returned by the API — *and* the panel does not
  /// offer it either. A language the panel still offers is kept as-is even with
  /// an empty label file; that case is covered by [fallbackLocale].
  ///
  /// This also covers a [defaultLanguageCode] that points at a language the
  /// panel does not (or no longer) serves: the target is
  /// [AppTranslation.fallbackLanguageCode] rather than [defaultLanguageCode]
  /// itself, so a misconfigured default cannot strand the app on a language
  /// with no labels.
  Future<void> _resetToDefaultLanguageIfUnusable() async {
    final code = currentLanguageCode;
    final fallbackCode = AppTranslation.fallbackLanguageCode;
    if (code == fallbackCode || AppTranslation.hasTranslationsFor(code)) {
      return;
    }

    // Still offered by the panel (or the list could not be refreshed at all,
    // e.g. offline): keep the choice and render it through the fallback.
    if (state.availableLanguages.any(
      (language) => language.languageCode == code,
    )) {
      return;
    }

    if (kDebugMode) {
      debugPrint(
        "Localization: no labels available for '$code', falling back to '$fallbackCode'",
      );
    }

    await _settingsRepository.setCurrentLanguageCode(fallbackCode);
    Get.updateLocale(Utils.getLocaleFromLanguageCode(fallbackCode));
    emit(
      AppLocalizationState(
        language: Utils.getLocaleFromLanguageCode(fallbackCode),
        availableLanguages: _withLanguage(
          state.availableLanguages,
          fallbackCode,
        ),
      ),
    );
  }

  /// Fetches, caches and applies the labels of [languageCode].
  ///
  /// Never throws and never blocks a language switch: an unreachable API, or a
  /// language whose label file has not been uploaded on the panel (`file_name`
  /// comes back as `{}`), simply leaves the local labels untouched so the
  /// bundled files and the English `fallbackLocale` keep supplying the text.
  Future<void> _refreshLabels(String languageCode) async {
    try {
      final labels = await _localizationRepository.fetchLabels(
        languageCode: languageCode,
      );
      if (labels.isEmpty) {
        if (kDebugMode) {
          debugPrint(
            "Localization: no labels uploaded for '$languageCode', keeping local ones",
          );
        }
        return;
      }

      await _localizationRepository.cacheLabels(
        languageCode: languageCode,
        labels: labels,
      );
      final changed = AppTranslation.overlayRemoteLabels({
        languageCode: labels,
      });
      if (kDebugMode) {
        debugPrint(
          "Localization: ${labels.length} labels fetched for '$languageCode' (changed: $changed)",
        );
      }

      // Repaint labels that are already on screen.
      if (changed && languageCode == currentLanguageCode) {
        Get.forceAppUpdate();
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint("Localization: labels fetch failed for '$languageCode': $e");
      }
    }
  }

  /// Switches the app language.
  ///
  /// Languages with local labels (bundled file or cached API labels) switch
  /// instantly and refresh their labels in the background. A language with no
  /// local labels yet has its labels fetched first, so the switch lands on
  /// translated text when the panel has a file for it.
  ///
  /// The switch always goes through. If the panel has no labels for the
  /// language — or the fetch fails — the app falls back to the bundled
  /// `en.json` through GetX's `fallbackLocale` instead of refusing to switch.
  Future<void> changeLanguage(String languageCode) async {
    if (languageCode == currentLanguageCode) {
      return;
    }

    if (AppTranslation.hasTranslationsFor(languageCode)) {
      _refreshLabels(languageCode);
    } else {
      emit(
        AppLocalizationState(
          language: state.language,
          availableLanguages: state.availableLanguages,
          languageChangeInProgress: true,
        ),
      );

      await _refreshLabels(languageCode);
    }

    await _settingsRepository.setCurrentLanguageCode(languageCode);
    Get.updateLocale(Utils.getLocaleFromLanguageCode(languageCode));
    emit(
      AppLocalizationState(
        language: Utils.getLocaleFromLanguageCode(languageCode),
        availableLanguages: state.availableLanguages,
      ),
    );
  }
}
