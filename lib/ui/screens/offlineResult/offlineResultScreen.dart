import 'package:eschool_saas_staff/cubits/exam/offlineExamStudentResultsCubit.dart';
import 'package:eschool_saas_staff/cubits/exam/offlineExamsWithClassesAndSessionYearsCubit.dart';
import 'package:eschool_saas_staff/data/models/classSection.dart';
import 'package:eschool_saas_staff/data/models/offlineExam.dart';
import 'package:eschool_saas_staff/data/models/sessionYear.dart';
import 'package:eschool_saas_staff/ui/screens/offlineResult/widgets/studentOfflineResultContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/appbarFilterBackgroundContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/customAppbar.dart';
import 'package:eschool_saas_staff/ui/widgets/customCircularProgressIndicator.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextButton.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/errorContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/filterButton.dart';
import 'package:eschool_saas_staff/ui/widgets/filterSelectionBottomsheet.dart';
import 'package:eschool_saas_staff/ui/widgets/noDataContainer.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/route_manager.dart';

class OfflineResultScreen extends StatefulWidget {
  const OfflineResultScreen({super.key});

  static Widget getRouteInstance() {
    //final arguments = Get.arguments as Map<String,dynamic>;
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => OfflineExamsWithClassesAndSessionYearsCubit(),
        ),
        BlocProvider(
          create: (context) => OfflineExamStudentResultsCubit(),
        ),
      ],
      child: const OfflineResultScreen(),
    );
  }

  static Map<String, dynamic> buildArguments() {
    return {};
  }

  @override
  State<OfflineResultScreen> createState() => _OfflineResultScreenState();
}

class _OfflineResultScreenState extends State<OfflineResultScreen> {
  ClassSection? _selectedClassSection;
  SessionYear? _selectedSessionYear;
  OfflineExam? _selectedOfflineExam;

  late final ScrollController _scrollController = ScrollController()
    ..addListener(scrollListener);

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      if (mounted) {
        context
            .read<OfflineExamsWithClassesAndSessionYearsCubit>()
            .getOfflineExamsWithSessionYearsAndClasses(
                sesstionYearId: _selectedSessionYear?.id);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.removeListener(scrollListener);
    _scrollController.dispose();
  }

  void scrollListener() {
    if (_scrollController.offset ==
        _scrollController.position.maxScrollExtent) {
      if (context.read<OfflineExamStudentResultsCubit>().hasMore()) {
        getMoreStudentResults();
      }
    }
  }

  void changeSelectedSessionYear(SessionYear value) {
    _selectedSessionYear = value;
    setState(() {});
  }

  void changeSelectedClassSection(ClassSection value) {
    _selectedClassSection = value;
    setState(() {});
  }

  void changeSelectedOfflineExam(OfflineExam? value) {
    _selectedOfflineExam = value;
    setState(() {});
  }

  void getStudentResults() {
    context.read<OfflineExamStudentResultsCubit>().getStudentResults(
        sessionYearId: _selectedSessionYear?.id ?? 0,
        classSectionId: _selectedClassSection?.id ?? 0,
        examId: _selectedOfflineExam?.id ?? 0);
  }

  void getMoreStudentResults() {
    context.read<OfflineExamStudentResultsCubit>().fetchMore(
        sessionYearId: _selectedSessionYear?.id ?? 0,
        classSectionId: _selectedClassSection?.id ?? 0,
        examId: _selectedOfflineExam?.id ?? 0);
  }

  Widget _buildStudentResults() {
    return BlocBuilder<OfflineExamStudentResultsCubit,
        OfflineExamStudentResultsState>(
      builder: (context, state) {
        if (state is OfflineExamStudentResultsFetchSuccess) {
          if (state.studentResults.isEmpty) {
            return Center(
              child: noDataContainer(
                titleKey: noStudentResultsFoundKey,
              ),
            );
          }
          return Align(
            alignment: Alignment.topCenter,
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: EdgeInsets.only(
                  top:
                      Utils.appContentTopScrollPadding(context: context) + 100),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(appContentHorizontalPadding),
                    color: Theme.of(context).colorScheme.surface,
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: appContentHorizontalPadding),
                          height: 40,
                          width: double.maxFinite,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: Theme.of(context).colorScheme.tertiary),
                          child:
                              LayoutBuilder(builder: (context, boxConstraints) {
                            return Row(
                              children: [
                                SizedBox(
                                  width: boxConstraints.maxWidth * (0.15),
                                  child:
                                      const CustomTextContainer(textKey: "#"),
                                ),
                                SizedBox(
                                  width: boxConstraints.maxWidth * (0.85),
                                  child: const CustomTextContainer(
                                      textKey: nameKey),
                                ),
                              ],
                            );
                          }),
                        ),
                        Container(
                          width: double.maxFinite,
                          decoration: BoxDecoration(
                              border: Border(
                                  right: BorderSide(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .tertiary),
                                  left: BorderSide(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .tertiary)),
                              borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(5),
                                  bottomRight: Radius.circular(5)),
                              color: Theme.of(context).colorScheme.surface),
                          child: Column(
                            children: List.generate(state.studentResults.length,
                                (index) {
                              if (context
                                  .read<OfflineExamStudentResultsCubit>()
                                  .hasMore()) {
                                //
                                if (index == state.studentResults.length - 1) {
                                  if (state
                                      is OfflineExamStudentResultsFetchFailure) {
                                    return Center(
                                      child: CustomTextButton(
                                          buttonTextKey: retryKey,
                                          onTapButton: () {
                                            getMoreStudentResults();
                                          }),
                                    );
                                  }

                                  return Center(
                                    child: CustomCircularProgressIndicator(
                                      indicatorColor:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                  );
                                }
                              }
                              return StudentOfflineResultContainer(
                                  examName: _selectedOfflineExam?.name ?? "-",
                                  studentResult: state.studentResults[index],
                                  index: index);
                            }).toList(),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        }

        if (state is OfflineExamStudentResultsFetchFailure) {
          return Center(
            child: ErrorContainer(
              errorMessage: state.errorMessage,
              onTapRetry: () {
                getStudentResults();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [
        BlocBuilder<OfflineExamsWithClassesAndSessionYearsCubit,
            OfflineExamsWithClassesAndSessionYearsState>(
          builder: (context, state) {
            if (state is OfflineExamsWithClassesAndSessionYearsFetchSuccess) {
              if (state.offlineExams.isEmpty ||
                  context
                      .read<OfflineExamsWithClassesAndSessionYearsCubit>()
                      .getAllClasses()
                      .isEmpty) {
                return noDataContainer(titleKey: noOfflineExamFoundKey);
              }
              return _buildStudentResults();
            }

            if (state is OfflineExamsWithClassesAndSessionYearsFetchFailure) {
              return Center(
                child: ErrorContainer(
                  errorMessage: state.errorMessage,
                  onTapRetry: () {
                    context
                        .read<OfflineExamsWithClassesAndSessionYearsCubit>()
                        .getOfflineExamsWithSessionYearsAndClasses(
                            sesstionYearId: _selectedSessionYear?.id);
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
        ),
        Align(
          alignment: Alignment.topCenter,
          child: BlocConsumer<OfflineExamsWithClassesAndSessionYearsCubit,
              OfflineExamsWithClassesAndSessionYearsState>(
            listener: (context, state) {
              if (state is OfflineExamsWithClassesAndSessionYearsFetchSuccess) {
                if (state.offlineExams.isNotEmpty) {
                  changeSelectedOfflineExam(state.offlineExams.first);
                } else {
                  changeSelectedOfflineExam(null);
                }

                if (context
                        .read<OfflineExamsWithClassesAndSessionYearsCubit>()
                        .getAllClasses()
                        .isNotEmpty &&
                    state.sessionYears.isNotEmpty) {
                  if (_selectedSessionYear?.id == null) {
                    changeSelectedSessionYear(state.sessionYears
                        .where((element) => element.isThisDefault())
                        .first);
                  }

                  if (_selectedClassSection?.id == null) {
                    changeSelectedClassSection(context
                        .read<OfflineExamsWithClassesAndSessionYearsCubit>()
                        .getAllClasses()
                        .first);
                  }

                  //
                  if (state.offlineExams.isNotEmpty) {
                    getStudentResults();
                  }
                }
              }
            },
            builder: (context, state) {
              return Column(
                children: [
                  const CustomAppbar(titleKey: offlineResultKey),
                  AppbarFilterBackgroundContainer(
                      child: LayoutBuilder(builder: (context, boxConstraints) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        FilterButton(
                            onTap: () {
                              if (state
                                      is OfflineExamsWithClassesAndSessionYearsFetchSuccess &&
                                  state.sessionYears.isNotEmpty) {
                                Utils.showBottomSheet(
                                    child:
                                        FilterSelectionBottomsheet<SessionYear>(
                                      onSelection: (value) {
                                        changeSelectedSessionYear(value!);
                                        context
                                            .read<
                                                OfflineExamsWithClassesAndSessionYearsCubit>()
                                            .getOfflineExamsWithSessionYearsAndClasses(
                                                sesstionYearId: value.id);
                                        Get.back();
                                      },
                                      selectedValue: _selectedSessionYear!,
                                      titleKey: sessionYearKey,
                                      values: state.sessionYears,
                                    ),
                                    context: context);
                              }
                            },
                            titleKey: _selectedSessionYear?.name ?? yearKey,
                            width: boxConstraints.maxWidth * (0.31)),
                        FilterButton(
                            onTap: () {
                              if (state
                                      is OfflineExamsWithClassesAndSessionYearsFetchSuccess &&
                                  state.offlineExams.isNotEmpty) {
                                Utils.showBottomSheet(
                                    child:
                                        FilterSelectionBottomsheet<OfflineExam>(
                                            onSelection: (value) {
                                              changeSelectedOfflineExam(value!);
                                              getStudentResults();
                                              Get.back();
                                            },
                                            selectedValue:
                                                _selectedOfflineExam!,
                                            titleKey: examKey,
                                            values: state.offlineExams),
                                    context: context);
                              }
                            },
                            titleKey: _selectedOfflineExam?.name ?? examKey,
                            width: boxConstraints.maxWidth * (0.31)),
                        FilterButton(
                            onTap: () {
                              if (state
                                      is OfflineExamsWithClassesAndSessionYearsFetchSuccess &&
                                  context
                                      .read<
                                          OfflineExamsWithClassesAndSessionYearsCubit>()
                                      .getAllClasses()
                                      .isNotEmpty) {
                                Utils.showBottomSheet(
                                    child: FilterSelectionBottomsheet<
                                            ClassSection>(
                                        onSelection: (value) {
                                          changeSelectedClassSection(value!);
                                          getStudentResults();
                                          Get.back();
                                        },
                                        selectedValue: _selectedClassSection!,
                                        titleKey: classKey,
                                        values: context
                                            .read<
                                                OfflineExamsWithClassesAndSessionYearsCubit>()
                                            .getAllClasses()),
                                    context: context);
                              }
                            },
                            titleKey:
                                _selectedClassSection?.fullName ?? classKey,
                            width: boxConstraints.maxWidth * (0.31)),
                      ],
                    );
                  }))
                ],
              );
            },
          ),
        )
      ],
    ));
  }
}
