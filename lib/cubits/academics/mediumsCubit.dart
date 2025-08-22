import 'package:eschool_saas_staff/data/models/medium.dart';
import 'package:eschool_saas_staff/data/repositories/academicRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class MediumsState {}

class MediumsInitial extends MediumsState {}

class MediumsFetchInProgress extends MediumsState {}

class MediumsFetchSuccess extends MediumsState {
  final List<Medium> mediums;

  MediumsFetchSuccess({required this.mediums});
}

class MediumsFetchFailure extends MediumsState {
  final String errorMessage;

  MediumsFetchFailure(this.errorMessage);
}

class MediumsCubit extends Cubit<MediumsState> {
  final AcademicRepository _academicRepository = AcademicRepository();

  MediumsCubit() : super(MediumsInitial());

  void getMediums() async {
    try {
      emit(MediumsFetchInProgress());

      emit(
          MediumsFetchSuccess(mediums: await _academicRepository.getMediums()));
    } catch (e) {
      emit(MediumsFetchFailure(e.toString()));
    }
  }
}
