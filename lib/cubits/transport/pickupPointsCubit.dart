import 'package:eschool_saas_staff/data/models/pickupPoint.dart';
import 'package:eschool_saas_staff/data/repositories/transportRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class PickupPointsState {}

class PickupPointsInitial extends PickupPointsState {}

class PickupPointsFetchInProgress extends PickupPointsState {}

class PickupPointsFetchSuccess extends PickupPointsState {
  final List<PickupPoint> pickupPoints;
  PickupPointsFetchSuccess({required this.pickupPoints});
}

class PickupPointsFetchFailure extends PickupPointsState {
  final String errorMessage;
  PickupPointsFetchFailure(this.errorMessage);
}

class PickupPointsCubit extends Cubit<PickupPointsState> {
  final TransportRepository _repository = TransportRepository();
  PickupPointsCubit() : super(PickupPointsInitial());

  Future<void> fetch() async {
    emit(PickupPointsFetchInProgress());
    try {
      final data = await _repository.getPickupPoints();
      emit(PickupPointsFetchSuccess(pickupPoints: data));
    } catch (e) {
      emit(PickupPointsFetchFailure(e.toString()));
    }
  }
}
