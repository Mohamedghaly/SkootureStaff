import 'package:eschool_saas_staff/data/models/transportPlanHistoryItem.dart';
import 'package:eschool_saas_staff/utils/api.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// ─── States ──────────────────────────────────────────────────

abstract class TransportPlanHistoryState {}

class TransportPlanHistoryInitial extends TransportPlanHistoryState {}

class TransportPlanHistoryFetchInProgress extends TransportPlanHistoryState {}

class TransportPlanHistoryFetchSuccess extends TransportPlanHistoryState {
  final List<TransportPlanHistoryItem> plans;
  TransportPlanHistoryFetchSuccess({required this.plans});
}

class TransportPlanHistoryFetchFailure extends TransportPlanHistoryState {
  final String errorMessage;
  TransportPlanHistoryFetchFailure(this.errorMessage);
}

// ─── Cubit ───────────────────────────────────────────────────

class TransportPlanHistoryCubit extends Cubit<TransportPlanHistoryState> {
  TransportPlanHistoryCubit() : super(TransportPlanHistoryInitial());

  Future<void> fetchPlans({required int userId}) async {
    emit(TransportPlanHistoryFetchInProgress());
    try {
      final result = await Api.post(
        url: Api.getCurrentPlan,
        useAuthToken: true,
        body: {'user_id': userId.toString()},
      );

      final raw = result['data'];
      final List<dynamic> list = raw is List ? raw : [];
      final plans = list
          .map((e) =>
              TransportPlanHistoryItem.fromJson(Map<String, dynamic>.from(e)))
          .toList();

      emit(TransportPlanHistoryFetchSuccess(plans: plans));
    } catch (e, st) {
      print("this is error for fetch current plan ${e} and ${st}");
      emit(TransportPlanHistoryFetchFailure(e.toString()));
    }
  }
}
