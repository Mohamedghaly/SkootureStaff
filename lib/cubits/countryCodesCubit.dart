import 'package:eschool_saas_staff/data/models/countryCode.dart';
import 'package:eschool_saas_staff/data/repositories/countryCodeRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class CountryCodesState {}

class CountryCodesInitial extends CountryCodesState {}

class CountryCodesFetchInProgress extends CountryCodesState {
  /// Results already on screen when this fetch started.
  ///
  /// Carried along so a search refresh doesn't blank the list mid-typing —
  /// only the very first load has nothing to show.
  final List<CountryCode> previousCountryCodes;

  CountryCodesFetchInProgress({this.previousCountryCodes = const []});
}

class CountryCodesFetchSuccess extends CountryCodesState {
  final List<CountryCode> countryCodes;

  CountryCodesFetchSuccess({required this.countryCodes});
}

class CountryCodesFetchFailure extends CountryCodesState {
  final String errorMessage;

  CountryCodesFetchFailure(this.errorMessage);
}

class CountryCodesCubit extends Cubit<CountryCodesState> {
  final CountryCodeRepository _countryCodeRepository = CountryCodeRepository();

  CountryCodesCubit() : super(CountryCodesInitial());

  /// Identifies the most recent request so a slow earlier search can never
  /// overwrite the results of a newer one.
  int _latestRequestId = 0;

  void getCountryCodes({String search = ""}) async {
    final requestId = ++_latestRequestId;

    emit(CountryCodesFetchInProgress(previousCountryCodes: _currentCodes()));

    try {
      final countryCodes =
          await _countryCodeRepository.getCountryCodes(search: search);
      if (_isOutdated(requestId)) return;
      emit(CountryCodesFetchSuccess(countryCodes: countryCodes));
    } catch (e) {
      if (_isOutdated(requestId)) return;
      emit(CountryCodesFetchFailure(e.toString()));
    }
  }

  bool _isOutdated(int requestId) => isClosed || requestId != _latestRequestId;

  List<CountryCode> _currentCodes() {
    final currentState = state;
    if (currentState is CountryCodesFetchSuccess) {
      return currentState.countryCodes;
    }
    if (currentState is CountryCodesFetchInProgress) {
      return currentState.previousCountryCodes;
    }
    return [];
  }
}
