import 'dart:io';

import 'package:eschool_saas_staff/data/models/appConfiguration.dart';
import 'package:eschool_saas_staff/data/repositories/settingsRepository.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

abstract class AppConfigurationState {}

class AppConfigurationInitial extends AppConfigurationState {}

class AppConfigurationFetchInProgress extends AppConfigurationState {}

class AppConfigurationFetchSuccess extends AppConfigurationState {
  final AppConfiguration appConfiguration;

  AppConfigurationFetchSuccess({required this.appConfiguration});
}

class AppConfigurationFetchFailure extends AppConfigurationState {
  final String errorMessage;

  AppConfigurationFetchFailure(this.errorMessage);
}

class AppConfigurationCubit extends Cubit<AppConfigurationState> {
  final SettingsRepository _settingsRepository = SettingsRepository();

  AppConfigurationCubit() : super(AppConfigurationInitial());

  Future<void> fetchAppConfiguration() async {
    emit(AppConfigurationFetchInProgress());
    try {
      final appConfiguration = AppConfiguration.fromJson(
        await _settingsRepository.getAppSettings(),
      );

      emit(AppConfigurationFetchSuccess(appConfiguration: appConfiguration));
    } catch (e) {
      emit(AppConfigurationFetchFailure(e.toString()));
    }
  }

  AppConfiguration getAppConfiguration() {
    if (state is AppConfigurationFetchSuccess) {
      return (state as AppConfigurationFetchSuccess).appConfiguration;
    }
    return AppConfiguration.fromJson({});
  }

  String getAppLink() {
    if (state is AppConfigurationFetchSuccess) {
      return Platform.isIOS
          ? (getAppConfiguration().teacherIosAppLink ?? "")
          : (getAppConfiguration().teacherAppLink ?? "");
    }
    return "";
  }

  String getAppVersion() {
    if (state is AppConfigurationFetchSuccess) {
      return Platform.isIOS
          ? (getAppConfiguration().teacherIosAppVersion ?? "")
          : (getAppConfiguration().teacherAppVersion ?? "");
    }
    return "";
  }

  bool appUnderMaintenance() {
    if (state is AppConfigurationFetchSuccess) {
      return getAppConfiguration().teacherAppMaintenance == "1";
    }
    return false;
  }

  bool forceUpdate() {
    if (state is AppConfigurationFetchSuccess) {
      return getAppConfiguration().teacherForceAppUpdate == "1";
    }
    return false;
  }
}
