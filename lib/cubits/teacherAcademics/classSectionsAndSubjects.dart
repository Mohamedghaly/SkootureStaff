import 'package:eschool_saas_staff/data/models/classSection.dart';
import 'package:eschool_saas_staff/data/models/teacherSubject.dart';
import 'package:eschool_saas_staff/data/repositories/academicRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class ClassSectionsAndSubjectsState {}

class ClassSectionsAndSubjectsInitial extends ClassSectionsAndSubjectsState {}

class ClassSectionsAndSubjectsFetchInProgress
    extends ClassSectionsAndSubjectsState {}

class ClassSectionsAndSubjectsFetchSuccess
    extends ClassSectionsAndSubjectsState {
  final List<ClassSection> classSections;
  final List<TeacherSubject> subjects;

  ClassSectionsAndSubjectsFetchSuccess(
      {required this.classSections, required this.subjects});
}

class ClassSectionsAndSubjectsFetchFailure
    extends ClassSectionsAndSubjectsState {
  final String errorMessage;

  ClassSectionsAndSubjectsFetchFailure(this.errorMessage);
}

class ClassSectionsAndSubjectsCubit
    extends Cubit<ClassSectionsAndSubjectsState> {
  final AcademicRepository _academicRepository = AcademicRepository();

  ClassSectionsAndSubjectsCubit() : super(ClassSectionsAndSubjectsInitial());

  void getClassSectionsAndSubjects(
      {dynamic classSectionId, int? teacherId}) async {
    try {
      emit(ClassSectionsAndSubjectsFetchInProgress());

      final classesResult = await _academicRepository.getClasses();

      List<ClassSection> classSections =
          List<ClassSection>.from(classesResult.classes);
      classSections
          .addAll(List<ClassSection>.from(classesResult.primaryClasses));

      // Get the class section ID safely
      List<int> classSectionIds = [];

      if (classSectionId != null) {
        // Handle if classSectionId is a List<ClassSection>
        if (classSectionId is List<ClassSection> && classSectionId.isNotEmpty) {
          classSectionIds = classSectionId.map((e) => e.id ?? 0).toList();
        }
        // Handle if classSectionId is a List<int>
        else if (classSectionId is List<int> && classSectionId.isNotEmpty) {
          classSectionIds = classSectionId;
        }
        // Handle if classSectionId is a single int value
        else if (classSectionId is int) {
          classSectionIds = [classSectionId];
        }
      }

      // If we still don't have any class section IDs, use the first one from classSections if available
      if (classSectionIds.isEmpty && classSections.isNotEmpty) {
        classSectionIds = [classSections.first.id ?? 0];
      }

      emit(
        ClassSectionsAndSubjectsFetchSuccess(
          classSections: classSections,
          subjects: await _academicRepository.getClassSectionSubjects(
            teacherId: teacherId ?? 0,
            classSectionIds: classSectionIds.isEmpty ? [0] : classSectionIds,
          ),
        ),
      );
    } catch (e) {
      emit(ClassSectionsAndSubjectsFetchFailure(e.toString()));
   
    }
  }

  Future<void> getNewSubjectsFromSelectedClassSectionIndex(
      {required List<int> newClassSectionId, required int teacherId}) async {
    if (state is ClassSectionsAndSubjectsFetchSuccess) {
      final successState = (state as ClassSectionsAndSubjectsFetchSuccess);
      emit(ClassSectionsAndSubjectsFetchSuccess(
          classSections: successState.classSections,
          subjects: await _academicRepository.getClassSectionSubjects(
              teacherId: teacherId, classSectionIds: newClassSectionId)));
    }
  }
}
