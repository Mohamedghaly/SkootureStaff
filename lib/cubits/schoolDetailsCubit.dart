import 'package:eschool_saas_staff/data/models/schoolDetails.dart';
import 'package:eschool_saas_staff/data/repositories/schoolDetailsRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class SchooldetailsState {}

class SchooldetailsInitial extends SchooldetailsState {}

class SchooldetailsFetchInProgress extends SchooldetailsState {}

class SchooldetailsFetchSuccess extends SchooldetailsState {
  final SchoolDetails schoolDetails;

  SchooldetailsFetchSuccess({required this.schoolDetails});
}

class SchooldetailsFetchFailure extends SchooldetailsState {
  final String errorMessage;

  SchooldetailsFetchFailure(this.errorMessage);
}

class SchooldetailsCubit extends Cubit<SchooldetailsState> {
  SchooldetailsCubit() : super(SchooldetailsInitial());

  Future<void> fetchSchooldetails() async {
    emit(SchooldetailsFetchInProgress());
    try {
      emit(
        SchooldetailsFetchSuccess(
          schoolDetails: await Schooldetailsfetch.fetchSchoolDetails(),
        ),
      );
    } catch (e) {
      emit(SchooldetailsFetchFailure(e.toString()));
    }
  }
}
