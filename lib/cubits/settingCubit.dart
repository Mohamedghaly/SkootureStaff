import 'package:eschool_saas_staff/data/repositories/settingsRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class SettingsState {}

class SettingsInitial extends SettingsState {}

class SettingsProgress extends SettingsState {}

class SettingsSuccess extends SettingsState {
  final String data;

  SettingsSuccess({required this.data});
}

class SettingsFailure extends SettingsState {
  final String errorMessage;

  SettingsFailure({required this.errorMessage});
}


class SettingsCubit extends Cubit<SettingsState> {
  final SettingsRepository _settingsRepository = SettingsRepository();
  SettingsCubit() : super(SettingsInitial());

  void getSettings(String type) async {
    try {
      emit(SettingsProgress());
      emit(SettingsSuccess(data: await _settingsRepository.getSetting(type)));
    } catch (e) {
      emit(SettingsFailure(errorMessage: e.toString()));
    }
  }
}
