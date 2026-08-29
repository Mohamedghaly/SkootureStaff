import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eschool_saas_staff/data/models/transportUserAttendance.dart';
import 'package:eschool_saas_staff/data/repositories/transportUserAttendanceRepository.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';

// States
abstract class TransportUserAttendanceState {}

class TransportUserAttendanceInitial extends TransportUserAttendanceState {}

class TransportUserAttendanceLoading extends TransportUserAttendanceState {}

class TransportUserAttendanceLoaded extends TransportUserAttendanceState {
  final TransportUserAttendanceData data;
  final AttendanceFilters currentFilters;

  TransportUserAttendanceLoaded({
    required this.data,
    required this.currentFilters,
  });
}

class TransportUserAttendanceError extends TransportUserAttendanceState {
  final String message;

  TransportUserAttendanceError(this.message);
}

// Cubit
class TransportUserAttendanceCubit extends Cubit<TransportUserAttendanceState> {
  final TransportUserAttendanceRepository _repository =
      TransportUserAttendanceRepository();

  AttendanceFilters _currentFilters = AttendanceFilters();
  List<FilterOption> _monthOptions = [];
  List<FilterOption> _tripTypeOptions = [];

  TransportUserAttendanceCubit() : super(TransportUserAttendanceInitial()) {
    _initializeOptions();
  }

  void _initializeOptions() {
    _monthOptions = _repository.getMonthOptions();
    _tripTypeOptions = _repository.getTripTypeOptions();

    // Set default filters to current month
    final currentMonth = DateTime.now().month.toString().padLeft(2, '0');
    _currentFilters = AttendanceFilters(
      month: currentMonth,
      tripType: 'all',
    );
  }

  /// Fetch attendance data
  Future<void> fetchAttendance({
    required int userId,
    String? month,
    String? tripType,
  }) async {
    try {
      emit(TransportUserAttendanceLoading());

      // Update current filters
      _currentFilters = AttendanceFilters(
        month: month ?? _currentFilters.month,
        tripType: tripType ?? _currentFilters.tripType,
      );

      final data = await _repository.getAttendanceList(
        userId: userId,
        month: _currentFilters.month,
        tripType: _currentFilters.tripType,
      );

      emit(TransportUserAttendanceLoaded(
        data: data,
        currentFilters: _currentFilters,
      ));
    } catch (e) {
      emit(TransportUserAttendanceError(e.toString()));
    }
  }

  /// Update filters and refetch data
  Future<void> updateFilters({
    required int userId,
    String? month,
    String? tripType,
  }) async {
    await fetchAttendance(
      userId: userId,
      month: month,
      tripType: tripType,
    );
  }

  /// Refresh current data
  Future<void> refresh(int userId) async {
    await fetchAttendance(
      userId: userId,
      month: _currentFilters.month,
      tripType: _currentFilters.tripType,
    );
  }

  // Getters
  List<FilterOption> get monthOptions => _monthOptions;
  List<FilterOption> get tripTypeOptions => _tripTypeOptions;
  AttendanceFilters get currentFilters => _currentFilters;

  String getCurrentMonthLabel() {
    if (_currentFilters.month == null)
      return Utils.getTranslatedLabel(selectMonthKey);

    // Get month label with year for display
    final labelWithYear =
        _repository.getCurrentMonthLabelWithYear(_currentFilters.month);
    return labelWithYear.isNotEmpty
        ? labelWithYear
        : Utils.getTranslatedLabel(selectMonthKey);
  }

  String getCurrentTripTypeLabel() {
    final option = _tripTypeOptions.firstWhere(
      (opt) => opt.value == (_currentFilters.tripType ?? 'all'),
      orElse: () =>
          FilterOption(label: Utils.getTranslatedLabel(allKey), value: 'all'),
    );
    return option.label;
  }

  // Helper method to check if data exists
  bool hasData() {
    final currentState = state;
    return currentState is TransportUserAttendanceLoaded &&
        currentState.data.hasData;
  }

  // Get current data
  TransportUserAttendanceData? getCurrentData() {
    final currentState = state;
    return currentState is TransportUserAttendanceLoaded
        ? currentState.data
        : null;
  }
}
