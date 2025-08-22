import 'package:eschool_saas_staff/cubits/academics/sessionYearsAndMediumsCubit.dart';
import 'package:eschool_saas_staff/cubits/exam/offlineExamsCubit.dart';
import 'package:eschool_saas_staff/data/models/medium.dart';
import 'package:eschool_saas_staff/data/models/offlineExam.dart';
import 'package:eschool_saas_staff/data/models/offlineExamTimetableSlot.dart';
import 'package:eschool_saas_staff/data/models/sessionYear.dart';
import 'package:eschool_saas_staff/ui/widgets/appbarFilterBackgroundContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/customAppbar.dart';
import 'package:eschool_saas_staff/ui/widgets/customBottomsheet.dart';
import 'package:eschool_saas_staff/ui/widgets/customCircularProgressIndicator.dart';
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

class ExamsScreen extends StatefulWidget {
  static Widget getRouteInstance() {
    //final arguments = Get.arguments as Map<String,dynamic>;
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => SessionYearsAndMediumsCubit(),
        ),
        BlocProvider(
          create: (context) => OfflineExamsCubit(),
        ),
      ],
      child: const ExamsScreen(),
    );
  }

  static Map<String, dynamic> buildArguments() {
    return {};
  }

  const ExamsScreen({super.key});

  @override
  State<ExamsScreen> createState() => _ExamsScreenState();
}

class _ExamsScreenState extends State<ExamsScreen> {
  SessionYear? _selectedSessionYear;
  Medium? _selectedMedium;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      if (mounted) {
        context.read<SessionYearsAndMediumsCubit>().getSessionYearsAndMediums();
      }
    });
  }

  void changeSelectedSessionYear(SessionYear sessionYear) {
    _selectedSessionYear = sessionYear;
    setState(() {});
  }

  void changeSelectedMedium(Medium medium) {
    _selectedMedium = medium;
    setState(() {});
  }

  void getExams() {
    context.read<OfflineExamsCubit>().getOfflineExams(
        status: 3,
        mediumId: _selectedMedium?.id,
        sessionYearId: _selectedSessionYear?.id);
  }

  Widget _buildTitleValueContainer(
      {required String titleKey,
      required String value,
      required bool showBorder}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomTextContainer(
          textKey: value,
          style: const TextStyle(fontSize: 15.0, fontWeight: FontWeight.w600),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        CustomTextContainer(
          textKey: titleKey,
          style: TextStyle(
              fontSize: 13.0,
              color: Theme.of(context)
                  .colorScheme
                  .secondary
                  .withValues(alpha: 0.76)),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildExamItem({required OfflineExam offlineExam}) {
    return Container(
      width: double.maxFinite,
      margin: EdgeInsets.symmetric(vertical: appContentHorizontalPadding),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Theme.of(context).colorScheme.tertiary)),
      child: LayoutBuilder(builder: (context, boxConstraints) {
        return Column(
          children: [
            Container(
              padding: EdgeInsets.all(appContentHorizontalPadding),
              width: boxConstraints.maxWidth,
              decoration: BoxDecoration(
                border: Border(
                  bottom:
                      BorderSide(color: Theme.of(context).colorScheme.tertiary),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: CustomTextContainer(
                      textKey: offlineExam.name ?? "-",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 16.0, fontWeight: FontWeight.w600),
                    ),
                  ),
                  (offlineExam.timetableSlots ?? []).isEmpty
                      ? const SizedBox()
                      : IconButton(
                          onPressed: () {
                            Utils.showBottomSheet(
                                child: OfflineExamTimetableBottomsheet(
                                    timetableSlots:
                                        offlineExam.timetableSlots ?? []),
                                context: context);
                          },
                          icon: const Icon(Icons.schedule))
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(appContentHorizontalPadding),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: _buildTitleValueContainer(
                        showBorder: false,
                        titleKey: classSectionKey,
                        value: offlineExam.className ?? "-"),
                  ),
                  SizedBox(
                    height: 35,
                    child: VerticalDivider(
                      color: Theme.of(context).colorScheme.tertiary,
                      thickness: 2,
                    ),
                  ),
                  Expanded(
                    child: _buildTitleValueContainer(
                      showBorder: true,
                      titleKey: examDateKey,
                      value: (offlineExam.examStartingDate ?? "").isEmpty
                          ? "-"
                          : offlineExam.examStartingDate!,
                    ),
                  ),
                  SizedBox(
                    height: 35,
                    child: VerticalDivider(
                      color: Theme.of(context).colorScheme.tertiary,
                      thickness: 2,
                    ),
                  ),
                  Expanded(
                    child: _buildTitleValueContainer(
                        showBorder: false,
                        titleKey: statusKey,
                        value: offlineExam.getOfflineStatusKey()),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildExamList() {
    return BlocBuilder<OfflineExamsCubit, OfflineExamsState>(
      builder: (context, state) {
        if (state is OfflineExamsFetchSuccess) {
          if (state.offlineExams.isEmpty) {
            return Center(
              child: noDataContainer(
                titleKey: noExamsKey,
              ),
            );
          }
          return Align(
            alignment: Alignment.topCenter,
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                  bottom: 70,
                  top:
                      Utils.appContentTopScrollPadding(context: context) + 100),
              child: Container(
                padding: EdgeInsets.all(appContentHorizontalPadding),
                color: Theme.of(context).colorScheme.surface,
                width: MediaQuery.of(context).size.width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ...state.offlineExams.map((offlineExam) =>
                        _buildExamItem(offlineExam: offlineExam))
                  ],
                ),
              ),
            ),
          );
        }

        if (state is OfflineExamsFetchFailure) {
          return Center(
            child: ErrorContainer(
              errorMessage: state.errorMessage,
              onTapRetry: () {
                getExams();
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
          BlocBuilder<SessionYearsAndMediumsCubit, SessionYearsAndMediumsState>(
            builder: (context, state) {
              if (state is SessionYearsAndMediumsFetchSuccess) {
                if (state.mediums.isNotEmpty && state.sessionYears.isNotEmpty) {
                  return _buildExamList();
                }
                return const SizedBox();
              }

              if (state is SessionYearsAndMediumsFetchFailure) {
                return Center(
                  child: ErrorContainer(
                    errorMessage: state.errorMessage,
                    onTapRetry: () {
                      context
                          .read<SessionYearsAndMediumsCubit>()
                          .getSessionYearsAndMediums();
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
            child: BlocConsumer<SessionYearsAndMediumsCubit,
                SessionYearsAndMediumsState>(
              listener: (context, state) {
                if (state is SessionYearsAndMediumsFetchSuccess) {
                  if (state.mediums.isNotEmpty &&
                      state.sessionYears.isNotEmpty) {
                    changeSelectedMedium(state.mediums.first);
                    changeSelectedSessionYear(state.sessionYears
                        .where((element) => element.isThisDefault())
                        .toList()
                        .first);
                    getExams();
                  }
                }
              },
              builder: (context, state) {
                return Column(
                  children: [
                    const CustomAppbar(titleKey: examsKey),
                    AppbarFilterBackgroundContainer(
                      child: LayoutBuilder(builder: (context, boxConstraints) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            FilterButton(
                              onTap: () {
                                if (state
                                        is SessionYearsAndMediumsFetchSuccess &&
                                    state.mediums.isNotEmpty) {
                                  Utils.showBottomSheet(
                                      child: FilterSelectionBottomsheet<Medium>(
                                          onSelection: (value) {
                                            changeSelectedMedium(value!);
                                            getExams();
                                            Get.back();
                                          },
                                          selectedValue:
                                              _selectedMedium ?? Medium(),
                                          titleKey: mediumKey,
                                          values: state.mediums),
                                      context: context);
                                }
                              },
                              titleKey: _selectedMedium?.name ?? mediumKey,
                              width: boxConstraints.maxWidth * (0.48),
                            ),
                            FilterButton(
                              onTap: () {
                                if (state
                                        is SessionYearsAndMediumsFetchSuccess &&
                                    state.sessionYears.isNotEmpty) {
                                  Utils.showBottomSheet(
                                      child: FilterSelectionBottomsheet<
                                              SessionYear>(
                                          onSelection: (value) {
                                            changeSelectedSessionYear(value!);
                                            getExams();
                                            Get.back();
                                          },
                                          selectedValue: _selectedSessionYear ??
                                              SessionYear(),
                                          titleKey: sessionYearKey,
                                          values: state.sessionYears),
                                      context: context);
                                }
                              },
                              titleKey: _selectedSessionYear?.name ?? yearKey,
                              width: boxConstraints.maxWidth * (0.48),
                            ),
                          ],
                        );
                      }),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class OfflineExamTimetableBottomsheet extends StatelessWidget {
  final List<OfflineExamTimeTableSlot> timetableSlots;
  const OfflineExamTimetableBottomsheet(
      {super.key, required this.timetableSlots});

  @override
  Widget build(BuildContext context) {
    return CustomBottomsheet(
        titleLabelKey: examTimetableKey,
        child: Column(
          children: timetableSlots
              .map((timetableSlot) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        title: CustomTextContainer(
                            textKey: timetableSlot.subject
                                    ?.getSybjectNameWithType() ??
                                "-"),
                        subtitle: CustomTextContainer(
                            textKey:
                                "${timetableSlot.date ?? "-"} (${timetableSlot.startTime ?? "-"} - ${timetableSlot.endTime ?? "-"})"),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: appContentHorizontalPadding),
                        child: Row(
                          children: [
                            const CustomTextContainer(textKey: totalMarksKey),
                            CustomTextContainer(
                              textKey: ": ${timetableSlot.totalMarks ?? 0}",
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            const Spacer(),
                            const CustomTextContainer(textKey: passingMarkKey),
                            CustomTextContainer(
                              textKey: ": ${timetableSlot.passingMarks ?? 0}",
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                      const Divider()
                    ],
                  ))
              .toList(),
        ));
  }
}
