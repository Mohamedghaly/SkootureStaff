import 'package:eschool_saas_staff/data/models/pickedStudyMaterial.dart';
import 'package:eschool_saas_staff/data/models/studyMaterial.dart';
import 'package:eschool_saas_staff/data/repositories/studyMaterialRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class UpdateStudyMaterialState {}

class UpdateStudyMaterialInitial extends UpdateStudyMaterialState {}

class UpdateStudyMaterialInProgress extends UpdateStudyMaterialState {}

class UpdateStudyMaterialSuccess extends UpdateStudyMaterialState {
  final StudyMaterial studyMaterial;

  UpdateStudyMaterialSuccess(this.studyMaterial);
}

class UpdateStudyMaterialFailure extends UpdateStudyMaterialState {
  final String errorMessage;

  UpdateStudyMaterialFailure(this.errorMessage);
}

class UpdateStudyMaterialCubit extends Cubit<UpdateStudyMaterialState> {
  final StudyMaterialRepository _studyMaterialRepository =
      StudyMaterialRepository();

  UpdateStudyMaterialCubit() : super(UpdateStudyMaterialInitial());

  Future<void> updateStudyMaterial({
    required int fileId,
    required PickedStudyMaterial pickedStudyMaterial,
  }) async {
    emit(UpdateStudyMaterialInProgress());
    try {
      final fileDetails = await pickedStudyMaterial.toJson();
      final result = await _studyMaterialRepository.updateStudyMaterial(
        fileId: fileId,
        fileDetails: fileDetails,
      );

      emit(UpdateStudyMaterialSuccess(result));
    } catch (e) {
      emit(UpdateStudyMaterialFailure(e.toString()));
    }
  }
}
