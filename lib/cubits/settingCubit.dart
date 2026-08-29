import 'package:eschool_saas_staff/data/repositories/authRepository.dart';
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

  /// Fetches settings based on user authentication status
  /// Automatically detects if user is logged in and uses appropriate API
  void getSettings(String type) async {
    try {
      emit(SettingsProgress());
      final isUserLoggedIn = AuthRepository.getIsLogIn();
      emit(SettingsSuccess(
        data: await _settingsRepository.getSetting(
          type,
          isUserLoggedIn: isUserLoggedIn,
        ),
      ));
    } catch (e) {
      emit(SettingsFailure(errorMessage: e.toString()));
    }
  }
}
