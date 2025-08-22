import 'package:eschool_saas_staff/cubits/academics/classesWithTeacherDetailsCubit.dart';
import 'package:eschool_saas_staff/data/models/subjectTeacher.dart';
import 'package:eschool_saas_staff/ui/widgets/customAppbar.dart';
import 'package:eschool_saas_staff/ui/widgets/customBottomsheet.dart';
import 'package:eschool_saas_staff/ui/widgets/customCircularProgressIndicator.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/errorContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/noDataContainer.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ClassesScreen extends StatefulWidget {
  const ClassesScreen({super.key});

  static Widget getRouteInstance() {
    //final arguments = Get.arguments as Map<String,dynamic>;
    return BlocProvider(
      create: (context) => ClassesWithTeacherDetailsCubit(),
      child: const ClassesScreen(),
    );
  }

  static Map<String, dynamic> buildArguments() {
    return {};
  }

  @override
  State<ClassesScreen> createState() => _ClassesScreenState();
}

class _ClassesScreenState extends State<ClassesScreen> {
  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      if (mounted) {
        context
            .read<ClassesWithTeacherDetailsCubit>()
            .getClassesWithTeacherDetails();
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: const CustomAppbar(titleKey: viewClassesKey),
        body: BlocBuilder<ClassesWithTeacherDetailsCubit,
            ClassesWithTeacherDetailsState>(
          builder: (context, state) {
            if (state is ClassesWithTeacherDetailsFetchSuccess) {
              return ListView.builder(
                  padding: EdgeInsets.all(appContentHorizontalPadding),
                  itemCount: state.classes.length,
                  itemBuilder: (context, index) {
                    final classSection = state.classes[index];
                    return Padding(
                      padding:
                          EdgeInsets.only(bottom: appContentHorizontalPadding),
                      child: ListTile(
                        onTap: () {
                          Utils.showBottomSheet(
                              child: ClassSubjectsBottomsheet(
                                  subjectTeachers:
                                      classSection.subjectTeachers ?? []),
                              context: context);
                        },
                        trailing: const Icon(Icons.arrow_right),
                        tileColor: Theme.of(context).colorScheme.surface,
                        title: CustomTextContainer(
                            textKey: classSection.fullName ?? ""),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CustomTextContainer(
                                textKey:
                                    "${Utils.getTranslatedLabel(classTeacherKey)} : ${classSection.getClassTeacherNames()}"),
                            (classSection.classDetails?.semesterName ?? '')
                                    .isEmpty
                                ? const SizedBox()
                                : CustomTextContainer(
                                    textKey:
                                        "${Utils.getTranslatedLabel(semesterKey)} : ${classSection.classDetails?.semesterName}"),
                          ],
                        ),
                      ),
                    );
                  });
            }
            if (state is ClassesWithTeacherDetailsFetchFailure) {
              return Center(
                child: ErrorContainer(
                  errorMessage: state.errorMessage,
                  onTapRetry: () {
                    context
                        .read<ClassesWithTeacherDetailsCubit>()
                        .getClassesWithTeacherDetails();
                  },
                ),
              );
            }
            return Center(
              child: CustomCircularProgressIndicator(
                indicatorColor: Theme.of(context).colorScheme.primary,
              ),
            );
          },
        ));
  }
}

class ClassSubjectsBottomsheet extends StatelessWidget {
  final List<SubjectTeacher> subjectTeachers;
  const ClassSubjectsBottomsheet({super.key, required this.subjectTeachers});

  @override
  Widget build(BuildContext context) {
    if (subjectTeachers.isEmpty) {
      return Center(
        child: noDataContainer(
          titleKey: noSubjectsKey,
        ),
      );
    }
    return CustomBottomsheet(
        titleLabelKey: classSubjectsKey,
        child: Column(
          children: subjectTeachers
              .map((subjectTeacher) => ListTile(
                    tileColor: Theme.of(context).colorScheme.surface,
                    title: CustomTextContainer(
                        textKey:
                            subjectTeacher.subject?.getSybjectNameWithType() ??
                                ''),
                    subtitle: CustomTextContainer(
                        textKey:
                            "${Utils.getTranslatedLabel(teacherKey)} : ${subjectTeacher.teacher?.fullName ?? '-'}"),
                  ))
              .toList(),
        ));
  }
}
