import 'package:eschool_saas_staff/cubits/academics/classesCubit.dart';
import 'package:eschool_saas_staff/cubits/teacherAcademics/attendence/attendanceCubit.dart';
import 'package:eschool_saas_staff/data/models/classSection.dart';
import 'package:eschool_saas_staff/ui/screens/teacherAcademics/widgets/holidayAttendanceContainer.dart';
import 'package:eschool_saas_staff/ui/styles/themeExtensions/customColorsExtension.dart';
import 'package:eschool_saas_staff/ui/widgets/appbarFilterBackgroundContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/customAppbar.dart';
import 'package:eschool_saas_staff/ui/widgets/customCircularProgressIndicator.dart';
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

class TeacherViewAttendanceScreen extends StatefulWidget {
  static Widget getRouteInstance() {
    //final arguments = Get.arguments as Map<String,dynamic>;
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AttendanceCubit(),
        ),
        BlocProvider(
          create: (context) => ClassesCubit(),
        ),
      ],
      child: const TeacherViewAttendanceScreen(),
    );
  }

  static Map<String, dynamic> buildArguments() {
    return {};
  }

  const TeacherViewAttendanceScreen({super.key});

  @override
  State<TeacherViewAttendanceScreen> createState() =>
      _TeacherViewAttendanceScreenState();
}

class _TeacherViewAttendanceScreenState
    extends State<TeacherViewAttendanceScreen> {
  bool? isPresentStatusOnly;
  DateTime _selectedDateTime = DateTime.now();
  ClassSection? _selectedClassSection;

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
        type: isPresentStatusOnly == null
            ? null
            : isPresentStatusOnly!
                ? 1
                : 0);
  }

  Widget _buildTotalTitleContainer(
      {required String value,
      required String title,
      required Color backgroundColor}) {
    return Container(
      height: 85,
      padding: EdgeInsets.symmetric(
          horizontal: appContentHorizontalPadding, vertical: 12.5),
      decoration: BoxDecoration(
          color: backgroundColor, borderRadius: BorderRadius.circular(5.0)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTextContainer(
            textKey: value,
            style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.w600),
          ),
          CustomTextContainer(
            textKey: title,
          ),
        ],
      ),
    );
  }

  Widget _buildStudentsContainer() {
    return Align(
      alignment: Alignment.topCenter,
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
            top: Utils.appContentTopScrollPadding(context: context) + 150),
        child: BlocBuilder<AttendanceCubit, AttendanceState>(
          builder: (context, state) {
            if (state is AttendanceFetchSuccess) {
              if (state.isHoliday) {
                return HolidayAttendanceContainer(
                  holiday: state.holidayDetails,
                );
              }
              if (state.attendance.isEmpty) {
                return const noDataContainer(titleKey: noAttendanceKey);
              }
              return Column(
                children: [
                  Row(
                    children: [
                      const SizedBox(
                        width: 15,
                      ),
                      Expanded(
                        child: _buildTotalTitleContainer(
                          backgroundColor: Theme.of(context)
                              .extension<CustomColors>()!
                              .totalStaffOverviewBackgroundColor!
                              .withValues(alpha: 0.15),
                          title: presentKey,
                          value: state.attendance
                              .where((element) => element.isPresent())
                              .length
                              .toString(),
                        ),
                      ),
                      const SizedBox(
                        width: 15,
                      ),
                      Expanded(
                        child: _buildTotalTitleContainer(
                          backgroundColor: Theme.of(context)
                              .extension<CustomColors>()!
                              .totalStudentOverviewBackgroundColor!
                              .withValues(alpha: 0.15),
                          title: absentKey,
                          value: state.attendance
                              .where((element) => !element.isPresent())
                              .length
                              .toString(),
                        ),
                      ),
                      const SizedBox(
                        width: 15,
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  StudentAttendanceContainer(
                    studentAttendances: state.attendance,
                    isForAddAttendance: false,
                  ),
                ],
              );
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
            } else if (state is AttendanceFetchInProgress) {
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
            return const Center();
          },
        ),
      ),
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
              _selectedClassSection = state.primaryClasses.first;
              setState(() {});
              getAttendance();
            }
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              const CustomAppbar(titleKey: viewAttendanceKey),
              AppbarFilterBackgroundContainer(
                height: 130,
                child: LayoutBuilder(builder: (context, boxConstraints) {
                  return Column(
                    children: [
                      SizedBox(
                        height: 40,
                        child: Row(
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
                                            if (_selectedClassSection !=
                                                value) {
                                              _selectedClassSection = value;
                                              setState(() {});
                                              getAttendance();
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
                                onTap: () {
                                  Utils.showBottomSheet(
                                      child: FilterSelectionBottomsheet<String>(
                                        onSelection: (value) {
                                          Get.back();
                                          bool refreshPage = false;
                                          if (value == allKey &&
                                              isPresentStatusOnly != null) {
                                            isPresentStatusOnly = null;
                                            refreshPage = true;
                                          } else if (value == absentKey &&
                                              isPresentStatusOnly != false) {
                                            isPresentStatusOnly = false;
                                            refreshPage = true;
                                          } else if (value == presentKey &&
                                              isPresentStatusOnly != true) {
                                            isPresentStatusOnly = true;
                                            refreshPage = true;
                                          }
                                          if (refreshPage) {
                                            setState(() {});
                                            getAttendance();
                                          }
                                        },
                                        selectedValue:
                                            isPresentStatusOnly == null
                                                ? allKey
                                                : isPresentStatusOnly!
                                                    ? presentKey
                                                    : absentKey,
                                        titleKey: statusKey,
                                        values: const [
                                          allKey,
                                          absentKey,
                                          presentKey
                                        ],
                                      ),
                                      context: context);
                                },
                                titleKey: isPresentStatusOnly == null
                                    ? statusKey
                                    : isPresentStatusOnly!
                                        ? presentKey
                                        : absentKey,
                                width: boxConstraints.maxWidth * (0.48)),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      SizedBox(
                        height: 40,
                        child: FilterButton(
                          onTap: () async {
                            final selectedDate = await showDatePicker(
                                context: context,
                                currentDate: _selectedDateTime,
                                firstDate: DateTime.now()
                                    .subtract(const Duration(days: 30)),
                                lastDate: DateTime.now()
                                    .add(const Duration(days: 30)));

                            if (selectedDate != null) {
                              _selectedDateTime = selectedDate;
                              setState(() {});
                              getAttendance();
                            }
                          },
                          titleKey: Utils.formatDate(_selectedDateTime),
                          width: boxConstraints.maxWidth,
                        ),
                      ),
                    ],
                  );
                }),
              ),
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
                return _buildStudentsContainer();
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
