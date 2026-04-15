import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eschool_saas_staff/data/models/transportRequest.dart';
import 'package:eschool_saas_staff/data/repositories/transportRequestRepository.dart';

// States
abstract class TransportRequestState {}

class TransportRequestInitial extends TransportRequestState {}

class TransportRequestFetchInProgress extends TransportRequestState {}

class TransportRequestFetchSuccess extends TransportRequestState {
  final List<TransportRequest> requests;

  TransportRequestFetchSuccess({required this.requests});
}

class TransportRequestFetchFailure extends TransportRequestState {
  final String errorMessage;

  TransportRequestFetchFailure(this.errorMessage);
}

class TransportRequestCubit extends Cubit<TransportRequestState> {
  final TransportRequestRepository _transportRequestRepository =
      TransportRequestRepository();

  List<TransportRequest> _cachedRequests = [];

  TransportRequestCubit() : super(TransportRequestInitial());

  // Getter for cached requests
  List<TransportRequest> get requests => _cachedRequests;

  // Check if we have any requests
  bool get hasRequests => _cachedRequests.isNotEmpty;

  // Get the first/main request (most common use case)
  TransportRequest? get mainRequest =>
      _cachedRequests.isNotEmpty ? _cachedRequests.first : null;

  /// Fetch transport requests for a user
  Future<void> fetchTransportRequests({required int userId}) async {
    emit(TransportRequestFetchInProgress());
    try {
      final response = await _transportRequestRepository.getTransportRequests(
        userId: userId,
      );

      if (response.error) {
        emit(TransportRequestFetchFailure(response.message));
        return;
      }

      _cachedRequests = response.data;
      emit(TransportRequestFetchSuccess(requests: response.data));
    } catch (e, st) {
      debugPrint("this is the Transport Request Error: $e");
      debugPrint("this is the Transport Request Stack Trace: $st");
      emit(TransportRequestFetchFailure(e.toString()));
    }
  }

  /// Clear cached data
  void clearData() {
    _cachedRequests = [];
    emit(TransportRequestInitial());
  }

  /// Check if a specific request status exists
  bool hasRequestWithStatus(String status) {
    return _cachedRequests
        .any((request) => request.status.toLowerCase() == status.toLowerCase());
  }

  /// Get requests by status
  List<TransportRequest> getRequestsByStatus(String status) {
    return _cachedRequests
        .where(
            (request) => request.status.toLowerCase() == status.toLowerCase())
        .toList();
  }
}
