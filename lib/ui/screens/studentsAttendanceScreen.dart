import 'package:eschool_saas_staff/cubits/academics/classesCubit.dart';
import 'package:eschool_saas_staff/cubits/student/studentAttendanceForStaffCubit.dart';
import 'package:eschool_saas_staff/cubits/teacherAcademics/attendence/attendanceCubit.dart';
import 'package:eschool_saas_staff/data/models/classSection.dart';
import 'package:eschool_saas_staff/ui/screens/teacherAcademics/widgets/holidayAttendanceContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/appbarFilterBackgroundContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/customAppbar.dart';
import 'package:eschool_saas_staff/ui/widgets/customCircularProgressIndicator.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextButton.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/errorContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/filterButton.dart';
import 'package:eschool_saas_staff/ui/widgets/filterSelectionBottomsheet.dart';
import 'package:eschool_saas_staff/ui/widgets/noDataContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/studentAttendenceItemContainer.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class StudentsAttendanceScreen extends StatefulWidget {
  const StudentsAttendanceScreen({super.key});

  static Widget getRouteInstance() {
    //final arguments = Get.arguments as Map<String, dynamic>;
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ClassesCubit(),
        ),
        BlocProvider(create: (context) => StudentAttendanceForStaffCubit()),
        BlocProvider(create: (context) => AttendanceCubit()),
      ],
      child: const StudentsAttendanceScreen(),
    );
  }

  static Map<String, dynamic> buildArguments() {
    return {};
  }

  @override
  State<StudentsAttendanceScreen> createState() =>
      _StudentsAttendanceScreenState();
}

class _StudentsAttendanceScreenState extends State<StudentsAttendanceScreen> {
  late DateTime _selectedDateTime = DateTime.now();

  ClassSection? _selectedClassSection;
  String _selectedAttendanceStatus = statusKey;

  late final ScrollController _scrollController = ScrollController()
    ..addListener(scrollListener);

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      if (mounted) {
        context.read<ClassesCubit>().getClasses();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void scrollListener() {
    if (_scrollController.offset ==
        _scrollController.position.maxScrollExtent) {
      if (context.read<StudentAttendanceForStaffCubit>().hasMore()) {
        getMoreStudentAttendance();
      }
    }
  }

  int? getStatus() {
    if (_selectedAttendanceStatus == absentKey) {
      return 0;
    }
    if (_selectedAttendanceStatus == presentKey) {
      return 1;
    }
    return null;
  }

  void changeSelectedClassSection(ClassSection classSection) {
    _selectedClassSection = classSection;
    setState(() {});
    getStudentAttendance();
  }

  void changeSelectedAttendanceStatus(String status) {
    _selectedAttendanceStatus = status;

    setState(() {});
    getStudentAttendance();
  }

  void getStudentAttendance() {
    context.read<StudentAttendanceForStaffCubit>().getStudentAttendance(
          classSectionId: (_selectedClassSection?.id ?? 0),
          date: _selectedDateTime,
          status: getStatus(),
        );
  }

  void getMoreStudentAttendance() {
    context.read<StudentAttendanceForStaffCubit>().fetchMore(
          classSectionId: (_selectedClassSection?.id ?? 0),
          date: _selectedDateTime,
          status: getStatus(),
        );
  }

  Widget _buildStudentsContainer() {
    return BlocBuilder<StudentAttendanceForStaffCubit,
        StudentAttendanceForStaffState>(
      builder: (context, staffState) {
        // Check if the staff state fetch is successful
        if (staffState is StudentAttendanceForStaffFetchSuccess) {
          // If it is a holiday, show the holiday container
          if (staffState.isholiday) {
            context.read<AttendanceCubit>().fetchAttendance(
                  classSectionId: (_selectedClassSection?.id ?? 0),
                  date: _selectedDateTime,
                  type: null,
                );

            return BlocBuilder<AttendanceCubit, AttendanceState>(
              builder: (context, attendanceState) {
                if (attendanceState is AttendanceFetchSuccess) {
                  return HolidayAttendanceContainer(
                    holiday: attendanceState.holidayDetails,
                  );
                } else if (attendanceState is AttendanceFetchInProgress) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (attendanceState is AttendanceFetchFailure) {
                  return Center(
                    child: Text(
                      attendanceState.errorMessage,
                      style: TextStyle(color: Colors.red),
                    ),
                  );
                }
                return Center(
                  child: Text("Loading holiday details..."),
                );
              },
            );
          }

          // If it is not a holiday, show the student attendance list
          return Align(
            alignment: Alignment.topCenter,
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: EdgeInsets.only(
                top: Utils.appContentTopScrollPadding(context: context) + 150,
              ),
              child: Container(
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.all(appContentHorizontalPadding),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                ),
                child: staffState.studentAttendances.isEmpty
                    ? const Center(
                        child: noDataContainer(
                          titleKey: attendanceNotTakenKey,
                        ),
                      )
                    : Column(
                        children: [
                          _buildTableHeader(),
                          ..._buildStudentAttendanceItems(staffState),
                        ],
                      ),
              ),
            ),
          );
        }

        if (staffState is StudentAttendanceForStaffFetchFailure) {
          return Center(
            child: ErrorContainer(
              errorMessage: staffState.errorMessage,
              onTapRetry: () {
                getStudentAttendance();
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
    );
  }

// Helper function to build the table header
  Widget _buildTableHeader() {
    return Container(
      width: double.infinity,
      height: 45,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(5.0),
          topLeft: Radius.circular(5.0),
        ),
        color: Theme.of(context).colorScheme.tertiary,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: appContentHorizontalPadding,
        vertical: 10,
      ),
      child: LayoutBuilder(
        builder: (context, boxConstraints) {
          const titleStyle = TextStyle(
            fontSize: 15.0,
            fontWeight: FontWeight.w600,
          );
          return Row(
            children: [
              SizedBox(
                width: boxConstraints.maxWidth * (0.2),
                child: const CustomTextContainer(
                  textKey: rollNoKey,
                  style: titleStyle,
                ),
              ),
              SizedBox(
                width: boxConstraints.maxWidth * (0.6),
                child: const CustomTextContainer(
                  textKey: nameKey,
                  style: titleStyle,
                ),
              ),
              SizedBox(
                width: boxConstraints.maxWidth * (0.2),
                child: const CustomTextContainer(
                  textKey: statusKey,
                  style: titleStyle,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

// Helper function to build student attendance items
  List<Widget> _buildStudentAttendanceItems(
      StudentAttendanceForStaffFetchSuccess staffState) {
    return List.generate(
      staffState.studentAttendances.length,
      (index) {
        final studentAttendance = staffState.studentAttendances[index];

        if (context.read<StudentAttendanceForStaffCubit>().hasMore()) {
          if (index == (staffState.studentAttendances.length - 1)) {
            if (staffState.fetchMoreError) {
              return Center(
                child: CustomTextButton(
                  buttonTextKey: retryKey,
                  onTapButton: () {
                    getMoreStudentAttendance();
                  },
                ),
              );
            }
            return Center(
              child: CustomCircularProgressIndicator(
                indicatorColor: Theme.of(context).colorScheme.primary,
              ),
            );
          }
        }

        return StudentAttendanceItemContainer(
          studentDetails: studentAttendance.studentDetails!,
          isPresent: getStudentAttendanceStatusFromValue(
                  studentAttendance.type ?? 0) ==
              StudentAttendanceStatus.present,
          showStatusPicker: false,
        );
      },
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
              if (context.read<ClassesCubit>().getAllClasses().isEmpty) {
                return const SizedBox();
              }
              return _buildStudentsContainer();
            }
            if (state is ClassesFetchFailure) {
              return Center(
                child: ErrorContainer(
                    onTapRetry: () {
                      context.read<ClassesCubit>().getClasses();
                    },
                    errorMessage: state.errorMessage),
              );
            }

            return Center(
              child: CustomCircularProgressIndicator(
                indicatorColor: Theme.of(context).colorScheme.primary,
              ),
            );
          },
        ),
        Align(
          alignment: Alignment.topCenter,
          child: BlocConsumer<ClassesCubit, ClassesState>(
            listener: (context, state) {
              if (state is ClassesFetchSuccess) {
                if (context.read<ClassesCubit>().getAllClasses().isNotEmpty) {
                  changeSelectedClassSection(
                      context.read<ClassesCubit>().getAllClasses().first);
                  getStudentAttendance();
                }
              }
            },
            builder: (context, state) {
              return Column(
                children: [
                  const CustomAppbar(titleKey: studentAttendanceKey),
                  AppbarFilterBackgroundContainer(
                    child: LayoutBuilder(builder: (context, boxConstraints) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          FilterButton(
                              onTap: () {
                                if (state is ClassesFetchSuccess &&
                                    context
                                        .read<ClassesCubit>()
                                        .getAllClasses()
                                        .isNotEmpty) {
                                  Utils.showBottomSheet(
                                      child: FilterSelectionBottomsheet<
                                              ClassSection>(
                                          onSelection: (value) {
                                            changeSelectedClassSection(value!);
                                            Get.back();
                                          },
                                          selectedValue: _selectedClassSection!,
                                          titleKey: classKey,
                                          values: context
                                              .read<ClassesCubit>()
                                              .getAllClasses()),
                                      context: context);
                                }
                              },
                              titleKey: _selectedClassSection == null
                                  ? classKey
                                  : (_selectedClassSection?.fullName ?? ""),
                              width: boxConstraints.maxWidth * (0.48)),
                          FilterButton(
                              onTap: () {
                                Utils.showBottomSheet(
                                    child: FilterSelectionBottomsheet(
                                        onSelection: (value) {
                                          changeSelectedAttendanceStatus(
                                              value!);
                                          Get.back();
                                        },
                                        selectedValue:
                                            _selectedAttendanceStatus,
                                        titleKey: statusKey,
                                        values: const [
                                          allKey,
                                          absentKey,
                                          presentKey
                                        ]),
                                    context: context);
                              },
                              titleKey: _selectedAttendanceStatus,
                              width: boxConstraints.maxWidth * (0.48)),
                        ],
                      );
                    }),
                  ),
                  InkWell(
                    onTap: () async {
                      final selectedDate = await showDatePicker(
                          context: context,
                          currentDate: _selectedDateTime,
                          firstDate:
                              DateTime.now().subtract(const Duration(days: 30)),
                          lastDate:
                              DateTime.now().add(const Duration(days: 30)));

                      if (selectedDate != null) {
                        _selectedDateTime = selectedDate;

                        setState(() {});
                        getStudentAttendance();
                      }
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: 50,
                      padding: EdgeInsets.symmetric(
                          horizontal: appContentHorizontalPadding,
                          vertical: 10),
                      decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          border: Border(
                              bottom: BorderSide(
                                  color:
                                      Theme.of(context).colorScheme.tertiary))),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_month),
                          const SizedBox(
                            width: 15,
                          ),
                          const CustomTextContainer(textKey: dateKey),
                          const SizedBox(
                            width: 10,
                          ),
                          CustomTextContainer(
                              textKey:
                                  "(${Utils.formatDate(_selectedDateTime)})")
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        )
      ],
    ));
  }
}
