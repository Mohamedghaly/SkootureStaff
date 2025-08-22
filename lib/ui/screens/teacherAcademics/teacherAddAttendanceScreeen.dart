import 'package:eschool_saas_staff/cubits/academics/classesCubit.dart';
import 'package:eschool_saas_staff/cubits/studentsByClassSectionCubit.dart';
import 'package:eschool_saas_staff/cubits/teacherAcademics/attendence/attendanceCubit.dart';
import 'package:eschool_saas_staff/cubits/teacherAcademics/attendence/submitAttendanceCubit.dart';
import 'package:eschool_saas_staff/data/models/classSection.dart';
import 'package:eschool_saas_staff/data/models/studentAttendance.dart';
import 'package:eschool_saas_staff/ui/screens/teacherAcademics/widgets/holidayAttendanceContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/appbarFilterBackgroundContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/customAppbar.dart';
import 'package:eschool_saas_staff/ui/widgets/customCircularProgressIndicator.dart';
import 'package:eschool_saas_staff/ui/widgets/customRoundedButton.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/errorContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/filterButton.dart';
import 'package:eschool_saas_staff/ui/widgets/filterSelectionBottomsheet.dart';
import 'package:eschool_saas_staff/ui/widgets/noDataContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/studentAttendanceContainer.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class TeacherAddAttendanceScreen extends StatefulWidget {
  static Widget getRouteInstance() {
    //final arguments = Get.arguments as Map<String,dynamic>;
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => SubmitAttendanceCubit(),
        ),
        BlocProvider(
          create: (context) => AttendanceCubit(),
        ),
        BlocProvider(create: (context) => StudentsByClassSectionCubit()),
        BlocProvider(
          create: (context) => ClassesCubit(),
        ),
      ],
      child: const TeacherAddAttendanceScreen(),
    );
  }

  static Map<String, dynamic> buildArguments() {
    return {};
  }

  const TeacherAddAttendanceScreen({super.key});

  @override
  State<TeacherAddAttendanceScreen> createState() =>
      _TeacherAddAttendanceScreenState();
}

class _TeacherAddAttendanceScreenState
    extends State<TeacherAddAttendanceScreen> {
  List<({StudentAttendanceStatus status, int studentId})> attendanceReport = [];

  DateTime _selectedDateTime = DateTime.now();
  ClassSection? _selectedClassSection;

  bool _isSendNotificationToGuardian = false;
  bool _isHoliday = false;

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      if (mounted) {
        context.read<ClassesCubit>().getClasses();
      }
    });
    super.initState();
  }

  void getAttendance() {
    context.read<AttendanceCubit>().fetchAttendance(
        date: _selectedDateTime,
        classSectionId: _selectedClassSection?.id ?? 0,
        type: null);
  }

  void getStudentList() {
    attendanceReport.clear();
    context.read<StudentsByClassSectionCubit>().fetchStudents(
          status: StudentListStatus.active,
          classSectionId: _selectedClassSection?.id ?? 0,
        );
  }

  void changeClassSectionSelection(ClassSection? newSelectedClassSection) {
    _selectedClassSection = newSelectedClassSection;

    setState(() {});
    if (newSelectedClassSection != null) {
      getAttendance();
      getStudentList();
    }
  }

  Widget _buildStudents({required List<StudentAttendance> attendance}) {
    return BlocBuilder<StudentsByClassSectionCubit,
        StudentsByClassSectionState>(
      builder: (BuildContext context, StudentsByClassSectionState state) {
        if (state is StudentsByClassSectionFetchSuccess) {
          if (state.studentDetailsList.isEmpty) {
            return const noDataContainer(titleKey: noStudentFoundKey);
          }
          if (_isHoliday) {
            return const SizedBox.shrink();
          }
          return StudentAttendanceContainer(
            studentAttendances: state.studentDetailsList
                .map((e) => StudentAttendance.fromStudentDetails(
                    studentDetails: e,
                    type: attendance
                        .firstWhereOrNull(
                            (element) => element.studentId == e.id)
                        ?.type))
                .toList(),
            onStatusChanged: (attendanceStatuses) {
              attendanceReport = attendanceStatuses;
            },
            isForAddAttendance: true,
          );
        } else if (state is StudentsByClassSectionFetchFailure) {
          return Center(
            child: Padding(
              padding:
                  EdgeInsets.only(top: topPaddingOfErrorAndLoadingContainer),
              child: ErrorContainer(
                errorMessage: state.errorMessage,
                onTapRetry: () {
                  getStudentList();
                },
              ),
            ),
          );
        } else {
          return Center(
            child: Padding(
              padding:
                  EdgeInsets.only(top: topPaddingOfErrorAndLoadingContainer),
              child: CustomCircularProgressIndicator(
                indicatorColor: Theme.of(context).colorScheme.primary,
              ),
            ),
          );
        }
      },
    );
  }

  Widget _buildStudentsContainer() {
    return Align(
      alignment: Alignment.topCenter,
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
            top: Utils.appContentTopScrollPadding(context: context) + 250,
            bottom: 130),
        child: BlocConsumer<AttendanceCubit, AttendanceState>(
          listener: (context, state) {
            if (state is AttendanceFetchSuccess) {
              setState(() {
                _isHoliday = state.isHoliday;
              });
            }
          },
          builder: (context, state) {
            if (state is AttendanceFetchSuccess) {
              if (_isHoliday) {
                return HolidayAttendanceContainer(
                  holiday: state.holidayDetails,
                );
              }
              return _buildStudents(attendance: state.attendance);
            } else if (state is AttendanceFetchFailure) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.only(
                      top: topPaddingOfErrorAndLoadingContainer),
                  child: ErrorContainer(
                    errorMessage: state.errorMessage,
                    onTapRetry: () {
                      getAttendance();
                    },
                  ),
                ),
              );
            } else {
              return Center(
                child: Padding(
                  padding: EdgeInsets.only(
                      top: topPaddingOfErrorAndLoadingContainer),
                  child: CustomCircularProgressIndicator(
                    indicatorColor: Theme.of(context).colorScheme.primary,
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return BlocBuilder<AttendanceCubit, AttendanceState>(
      builder: (context, state) {
        if (state is AttendanceFetchSuccess) {
          return BlocConsumer<SubmitAttendanceCubit, SubmitAttendanceState>(
              listener: (context, submitAttendanceState) {
            if (submitAttendanceState is SubmitAttendanceSuccess) {
              Utils.showSnackBar(
                context: context,
                message: attendanceSubmittedSuccessfullyKey,
              );
            } else if (submitAttendanceState is SubmitAttendanceFailure) {
              Utils.showSnackBar(
                context: context,
                message: submitAttendanceState.errorMessage,
              );
            }
          }, builder: (context, submitAttendanceState) {
            return Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  padding: EdgeInsets.all(appContentHorizontalPadding),
                  decoration: BoxDecoration(boxShadow: const [
                    BoxShadow(
                        color: Colors.black12, blurRadius: 1, spreadRadius: 1)
                  ], color: Theme.of(context).colorScheme.surface),
                  width: MediaQuery.of(context).size.width,
                  height: 70,
                  child: CustomRoundedButton(
                    height: 40,
                    widthPercentage: 1.0,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    buttonTitle: submitKey,
                    showBorder: false,
                    onTap: () {
                      if (submitAttendanceState is SubmitAttendanceInProgress) {
                        return;
                      }

                      if (attendanceReport.isEmpty) {
                        return;
                      }
                      context.read<SubmitAttendanceCubit>().submitAttendance(
                            isHoliday: _isHoliday,
                            sendAbsentNotification:
                                _isSendNotificationToGuardian,
                            dateTime: _selectedDateTime,
                            classSectionId: _selectedClassSection?.id ?? 0,
                            attendanceReport:
                                _isHoliday ? [] : attendanceReport,
                          );
                    },
                    child: submitAttendanceState is SubmitAttendanceInProgress
                        ? const CustomCircularProgressIndicator(
                            strokeWidth: 2,
                            widthAndHeight: 20,
                          )
                        : null,
                  ),
                ));
          });
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildAppbarAndFilters() {
    return Align(
      alignment: Alignment.topCenter,
      child: BlocConsumer<ClassesCubit, ClassesState>(
        listener: (context, state) {
          if (state is ClassesFetchSuccess) {
            if (_selectedClassSection == null &&
                state.primaryClasses.isNotEmpty) {
              changeClassSectionSelection(state.primaryClasses.first);
            }
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              const CustomAppbar(titleKey: addAttendanceKey),
              AppbarFilterBackgroundContainer(
                child: LayoutBuilder(
                  builder: (context, boxConstraints) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        FilterButton(
                            onTap: () {
                              if (state is ClassesFetchSuccess &&
                                  state.primaryClasses.isNotEmpty) {
                                Utils.showBottomSheet(
                                    child: FilterSelectionBottomsheet<
                                        ClassSection>(
                                      onSelection: (value) {
                                        Get.back();
                                        if (_selectedClassSection != value) {
                                          changeClassSectionSelection(value);
                                        }
                                      },
                                      selectedValue: _selectedClassSection!,
                                      titleKey: classKey,
                                      values: state.primaryClasses,
                                    ),
                                    context: context);
                              }
                            },
                            titleKey: _selectedClassSection?.id == null
                                ? classKey
                                : (_selectedClassSection?.fullName ?? ""),
                            width: boxConstraints.maxWidth * (0.48)),
                        FilterButton(
                          onTap: () async {
                            final selectedDate = await Utils.openDatePicker(
                                context: context,
                                inititalDate: _selectedDateTime,
                                lastDate: DateTime.now(),
                                firstDate: DateTime.now()
                                    .subtract(const Duration(days: 30)));

                            if (selectedDate != null) {
                              _selectedDateTime = selectedDate;
                              setState(() {});
                              getAttendance();
                            }
                          },
                          titleKey: Utils.formatDate(_selectedDateTime),
                          width: boxConstraints.maxWidth * (0.48),
                        ),
                      ],
                    );
                  },
                ),
              ),
              AppbarFilterBackgroundContainer(
                  height: 80,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: () {
                          setState(() {
                            _isSendNotificationToGuardian =
                                !_isSendNotificationToGuardian;
                          });
                        },
                        child: Container(
                          height: 18,
                          width: 18,
                          margin: const EdgeInsets.only(top: 2.5),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                          child: _isSendNotificationToGuardian
                              ? const Icon(
                                  Icons.check,
                                  size: 15.0,
                                )
                              : const SizedBox(),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      const Expanded(
                        child: CustomTextContainer(
                          textKey: sendNotificationToGuardianIfAbsentKey,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  )),
              AppbarFilterBackgroundContainer(
                  height: 60,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: () {
                          setState(() {
                            _isHoliday = !_isHoliday;
                          });
                        },
                        child: Container(
                          height: 18,
                          width: 18,
                          margin: const EdgeInsets.only(top: 2.5),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                          child: _isHoliday
                              ? const Icon(
                                  Icons.check,
                                  size: 15.0,
                                )
                              : const SizedBox(),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      const Expanded(
                        child: CustomTextContainer(
                          textKey: holidayKey,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  )),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          BlocBuilder<ClassesCubit, ClassesState>(
            builder: (context, state) {
              if (state is ClassesFetchSuccess) {
                if (state.primaryClasses.isEmpty) {
                  return const noDataContainer(titleKey: noClassSectionKey);
                }
                return Stack(children: [
                  _buildStudentsContainer(),
                  SafeArea(child: _buildSubmitButton()),
                ]);
              }
              if (state is ClassesFetchFailure) {
                return Center(
                    child: ErrorContainer(
                  errorMessage: state.errorMessage,
                  onTapRetry: () {
                    context.read<ClassesCubit>().getClasses();
                  },
                ));
              }
              return Center(
                child: CustomCircularProgressIndicator(
                  indicatorColor: Theme.of(context).colorScheme.primary,
                ),
              );
            },
          ),
          _buildAppbarAndFilters(),
        ],
      ),
    );
  }
}
