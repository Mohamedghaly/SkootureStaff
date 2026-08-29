import 'package:eschool_saas_staff/cubits/leave/applyLeaveCubit.dart';
import 'package:eschool_saas_staff/cubits/leave/leaveSettingsCubit.dart';
import 'package:eschool_saas_staff/ui/screens/teacherAcademics/widgets/customFileContainer.dart';
import 'package:eschool_saas_staff/ui/styles/themeExtensions/customColorsExtension.dart';
import 'package:eschool_saas_staff/ui/widgets/customAppbar.dart';
import 'package:eschool_saas_staff/ui/widgets/customCircularProgressIndicator.dart';
import 'package:eschool_saas_staff/ui/widgets/customRoundedButton.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextFieldContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/errorContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/textWithFadedBackgroundContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/uploadImageOrFileButton.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class ApplyLeaveScreen extends StatefulWidget {
  const ApplyLeaveScreen({super.key});

  static Widget getRouteInstance() => MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => ApplyLeaveCubit(),
          ),
          BlocProvider(
            create: (context) => LeaveSettingsAndSessionYearsCubit(),
          ),
        ],
        child: const ApplyLeaveScreen(),
      );

  @override
  State<ApplyLeaveScreen> createState() => _ApplyLeaveScreenState();
}

class _ApplyLeaveScreenState extends State<ApplyLeaveScreen> {
  late final TextEditingController _textEditingController =
      TextEditingController();

  DateTime? _selectedFromDate;
  DateTime? _selectedToDate;

  Map<DateTime, String> _leaveDays = {};

  /// Maps dates that are public holidays to their holiday title
  Map<DateTime, String> _publicHolidayNames = {};

  List<PlatformFile> _uploadedFiles = [];

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      if (mounted) {
        context
            .read<LeaveSettingsAndSessionYearsCubit>()
            .getLeaveSettingsAndSessionYears();
      }
    });
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  Future<void> _addFiles() async {
    final result = await Utils.openFilePicker(
      context: context,
    );
    if (result != null) {
      _uploadedFiles.addAll(result.files);
      setState(() {});
    }
  }

  void generateLeaveDays() {
    List<int> holidayWeekdays =
        context.read<LeaveSettingsAndSessionYearsCubit>().getHolidayWeekDays();
    Map<DateTime, String> publicHolidayDates = context
        .read<LeaveSettingsAndSessionYearsCubit>()
        .getPublicHolidayDates();
    _leaveDays = {};
    _publicHolidayNames = {};

    // Calculate the number of days between from and to date (inclusive)
    int differenceInDays =
        _selectedToDate!.difference(_selectedFromDate!).inDays;

    // Add all days from start date to end date (inclusive)
    for (var i = 0; i <= differenceInDays; i++) {
      final date = _selectedFromDate!.add(Duration(days: i));
      final normalizedDate = DateTime(date.year, date.month, date.day);

      // Check if this day is a weekly holiday (e.g., Sunday, Monday)
      bool isWeeklyHoliday = holidayWeekdays.contains(date.weekday);

      // Check if this day is a public holiday
      String? publicHolidayTitle = publicHolidayDates[normalizedDate];
      bool isPublicHoliday = publicHolidayTitle != null;

      if (isWeeklyHoliday) {
        _leaveDays.addAll({date: 'holiday'});
      } else if (isPublicHoliday) {
        _leaveDays.addAll({date: 'public_holiday'});
        _publicHolidayNames[date] = publicHolidayTitle;
      } else {
        // Regular working day
        _leaveDays.addAll({date: fullDayKey});
      }
    }
  }

  void onTapFromDate() async {
    final endDateString = context
        .read<LeaveSettingsAndSessionYearsCubit>()
        .getCurrentSessionYear()
        .endDate;

    // Parse the end date safely using Utils
    final endDate =
        endDateString != null ? Utils.parseDateSafely(endDateString) : null;

    if (endDate == null) {
      Utils.showSnackBar(
          message: invalidSessionYearEndDateKey, context: context);
      return;
    }

    // Check if session year has ended
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    if (endDate.isBefore(todayDate)) {
      Utils.showSnackBar(message: sessionYearEndedKey, context: context);
      return;
    }

    final selectedDate = await showDatePicker(
        context: context, firstDate: todayDate, lastDate: endDate);
    if (selectedDate != null) {
      _selectedFromDate = selectedDate;

      if (_selectedToDate != null) {
        if (_selectedFromDate!.isAfter(_selectedToDate!)) {
          _selectedToDate = null;
          _leaveDays = {};
        } else {
          generateLeaveDays();
        }
      }
      setState(() {});
    }
  }

  void onTapToDate() async {
    if (_selectedFromDate != null) {
      final endDateString = context
          .read<LeaveSettingsAndSessionYearsCubit>()
          .getCurrentSessionYear()
          .endDate;

      // Parse the end date safely using Utils
      final endDate =
          endDateString != null ? Utils.parseDateSafely(endDateString) : null;

      if (endDate == null) {
        Utils.showSnackBar(
            message: invalidSessionYearEndDateKey, context: context);
        return;
      }

      // Check if session year has ended
      final today = DateTime.now();
      final todayDate = DateTime(today.year, today.month, today.day);

      if (endDate.isBefore(todayDate)) {
        Utils.showSnackBar(message: sessionYearEndedKey, context: context);
        return;
      }

      final selectedDate = await showDatePicker(
          context: context, firstDate: _selectedFromDate!, lastDate: endDate);
      if (selectedDate != null) {
        _selectedToDate = selectedDate;

        generateLeaveDays();
        setState(() {});
      }
    } else {
      Utils.showSnackBar(message: pleaseSelectFromDateKey, context: context);
    }
  }

  Widget _buildSubmitLeaveContainer() {
    return BlocConsumer<ApplyLeaveCubit, ApplyLeaveState>(
      listener: (context, state) {
        if (state is ApplyLeaveSuccess) {
          _leaveDays = {};
          _textEditingController.clear();
          _selectedFromDate = null;
          _selectedToDate = null;
          _uploadedFiles = [];
          _publicHolidayNames = {};
          setState(() {});
          Utils.showSnackBar(
              message: leaveAppliedSuccessfullyKey, context: context);
        } else if (state is ApplyLeaveFailure) {
          Utils.showSnackBar(message: state.errorMessage, context: context);
        }
      },
      builder: (context, state) {
        return PopScope(
          canPop: state is! ApplyLeaveInProgress,
          child: Container(
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            color: Theme.of(context).colorScheme.surface,
            child: CustomRoundedButton(
              height: 35,
              widthPercentage: 1.0,
              backgroundColor: Theme.of(context).colorScheme.primary,
              buttonTitle: submitLeaveKey,
              radius: 5,
              textSize: 16.0,
              fontWeight: FontWeight.w500,
              showBorder: false,
              child: state is ApplyLeaveInProgress
                  ? const CustomCircularProgressIndicator()
                  : null,
              onTap: () {
                if (state is ApplyLeaveInProgress) {
                  return;
                }

                if (_textEditingController.text.trim().isEmpty) {
                  Utils.showSnackBar(
                      message: pleaseAddReasonKey, context: context);
                  return;
                }

                if (_selectedFromDate == null) {
                  Utils.showSnackBar(
                      message: pleaseSelectFromDateKey, context: context);
                  return;
                }

                if (_selectedToDate == null) {
                  Utils.showSnackBar(
                      message: pleaseSelectToDateKey, context: context);
                  return;
                }

                // Check if there are any actual working days to apply leave for
                final hasWorkingDays = _leaveDays.values.any(
                    (value) => value != 'holiday' && value != 'public_holiday');
                if (!hasWorkingDays) {
                  Utils.showSnackBar(
                      message: noLeaveRequiredForHolidayWeekendKey,
                      context: context);
                  return;
                }

                context.read<ApplyLeaveCubit>().applyLeave(
                    attachmentPaths: _uploadedFiles
                        .map((file) => (file.path ?? ""))
                        .toList(),
                    reason: _textEditingController.text.trim(),
                    leaveDays: _leaveDays);
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildBackgroundContainer({required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15.0),
      decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).colorScheme.tertiary),
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(5)),
      padding: EdgeInsets.symmetric(
          horizontal: appContentHorizontalPadding, vertical: 5),
      child: child,
    );
  }

  Widget _buildLeaveTypeContainer(
      {required String leaveTypeKey,
      required DateTime dateTime,
      required double heightAndWidth,
      required bool isSelected}) {
    return GestureDetector(
      onTap: () {
        if (!isSelected) {
          _leaveDays[dateTime] = leaveTypeKey;
          setState(() {});
        }
      },
      child: Container(
        width: heightAndWidth,
        height: heightAndWidth,
        decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).colorScheme.tertiary),
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(8)),
        child: Column(
          children: [
            const Spacer(),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: Theme.of(context).colorScheme.secondary)),
              padding: const EdgeInsets.all(3.0),
              child: isSelected
                  ? Container(
                      decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.secondary,
                          shape: BoxShape.circle),
                    )
                  : const SizedBox(),
            ),
            const Spacer(),
            CustomTextContainer(
              textKey: leaveTypeKey,
              style: const TextStyle(fontSize: 13.0),
            ),
            const SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaveDaysWithReasonContainer({required DateTime dateTime}) {
    final selectedLeaveTypeKey = _leaveDays[dateTime];
    final isWeeklyHoliday = selectedLeaveTypeKey == 'holiday';
    final isPublicHoliday = selectedLeaveTypeKey == 'public_holiday';
    final isHoliday = isWeeklyHoliday || isPublicHoliday;

    // Get public holiday name if applicable
    final publicHolidayTitle = _publicHolidayNames[dateTime];

    return Container(
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.only(
          bottom: 20.0,
          left: appContentHorizontalPadding,
          right: appContentHorizontalPadding),
      padding: EdgeInsets.all(appContentHorizontalPadding),
      decoration: BoxDecoration(
          color: isHoliday
              ? Theme.of(context).colorScheme.surface.withValues(alpha: 0.5)
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(8)),
      child: LayoutBuilder(builder: (context, boxConstraints) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextWithFadedBackgroundContainer(
                backgroundColor: isHoliday
                    ? Colors.red.withValues(alpha: 0.1)
                    : Theme.of(context)
                        .extension<CustomColors>()!
                        .totalStaffOverviewBackgroundColor!
                        .withValues(alpha: 0.1),
                textColor: isHoliday
                    ? Colors.red
                    : Theme.of(context)
                        .extension<CustomColors>()!
                        .totalStaffOverviewBackgroundColor!,
                titleKey: isWeeklyHoliday
                    ? "${Utils.formatDate(dateTime)} (${Utils.weekDays[dateTime.weekday - 1].tr}) - ${Utils.getTranslatedLabel(holidayWeekendKey)}"
                    : isPublicHoliday
                        ? "${Utils.formatDate(dateTime)} (${Utils.weekDays[dateTime.weekday - 1].tr}) - $publicHolidayTitle"
                        : "${Utils.formatDate(dateTime)} (${Utils.weekDays[dateTime.weekday - 1].tr})"),
            const SizedBox(
              height: 15.0,
            ),
            if (isHoliday)
              // Show message for holiday/weekend/public holiday days
              Center(
                child: CustomTextContainer(
                  textKey: isPublicHoliday
                      ? "${Utils.getTranslatedLabel(publicHolidayKey)}: $publicHolidayTitle"
                      : Utils.getTranslatedLabel(
                          noLeaveRequiredForHolidayWeekendKey),
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              )
            else
              // Show normal leave type options for working days
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildLeaveTypeContainer(
                      dateTime: dateTime,
                      leaveTypeKey: fullDayKey,
                      heightAndWidth: boxConstraints.maxWidth * (0.3),
                      isSelected: selectedLeaveTypeKey == fullDayKey),
                  _buildLeaveTypeContainer(
                      dateTime: dateTime,
                      leaveTypeKey: firstHalfKey,
                      heightAndWidth: boxConstraints.maxWidth * (0.3),
                      isSelected: selectedLeaveTypeKey == firstHalfKey),
                  _buildLeaveTypeContainer(
                      dateTime: dateTime,
                      leaveTypeKey: secondHalfKey,
                      heightAndWidth: boxConstraints.maxWidth * (0.3),
                      isSelected: selectedLeaveTypeKey == secondHalfKey),
                ],
              ),
          ],
        );
      }),
    );
  }

  Widget _buildGeneratedLeaveDaysContainer() {
    List<DateTime> dateTimes = _leaveDays.keys.toList();
    if (dateTimes.isEmpty) {
      return const SizedBox();
    }
    return Column(
      children: dateTimes
          .map((dateTime) =>
              _buildLeaveDaysWithReasonContainer(dateTime: dateTime))
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [
        BlocBuilder<LeaveSettingsAndSessionYearsCubit,
            LeaveSettingsAndSessionYearsState>(
          builder: (context, state) {
            if (state is LeaveSettingsAndSessionYearsFetchSuccess) {
              return Align(
                alignment: Alignment.topCenter,
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(
                      bottom: 100,
                      top: Utils.appContentTopScrollPadding(context: context)),
                  child: Column(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width,
                        color: Theme.of(context).colorScheme.surface,
                        padding: EdgeInsets.all(appContentHorizontalPadding),
                        child: Column(
                          children: [
                            CustomTextFieldContainer(
                              textEditingController: _textEditingController,
                              maxLines: 5,
                              hintTextKey: reasonKey,
                            ),
                            _buildBackgroundContainer(
                                child: GestureDetector(
                              onTap: onTapFromDate,
                              child: Container(
                                decoration: BoxDecoration(
                                    border:
                                        Border.all(color: Colors.transparent)),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                child: Row(
                                  children: [
                                    const CustomTextContainer(
                                        textKey: fromDateKey),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    _selectedFromDate != null
                                        ? CustomTextContainer(
                                            textKey:
                                                "${Utils.formatDate(_selectedFromDate!)} (${Utils.weekDays[_selectedFromDate!.weekday - 1].tr})")
                                        : const SizedBox()
                                  ],
                                ),
                              ),
                            )),
                            _buildBackgroundContainer(
                                child: GestureDetector(
                              onTap: onTapToDate,
                              child: Container(
                                decoration: BoxDecoration(
                                    border:
                                        Border.all(color: Colors.transparent)),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                child: Row(
                                  children: [
                                    const CustomTextContainer(
                                        textKey: toDateKey),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    _selectedToDate != null
                                        ? CustomTextContainer(
                                            textKey:
                                                "${Utils.formatDate(_selectedToDate!)} (${Utils.weekDays[_selectedToDate!.weekday - 1].tr})")
                                        : const SizedBox()
                                  ],
                                ),
                              ),
                            )),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 25,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: appContentHorizontalPadding,
                        ),
                        child: Column(
                          children: [
                            UploadImageOrFileButton(
                              uploadFile: true,
                              includeImageFileOnlyAllowedNote: true,
                              onTap: () {
                                _addFiles();
                              },
                            ),

                            ///[Attahchments for the leave]
                            ...List.generate(
                                _uploadedFiles.length, (index) => index).map(
                              (index) => Padding(
                                padding: const EdgeInsets.only(top: 15),
                                child: CustomFileContainer(
                                  backgroundColor:
                                      Theme.of(context).colorScheme.surface,
                                  onDelete: () {
                                    _uploadedFiles.removeAt(index);
                                    setState(() {});
                                  },
                                  title: _uploadedFiles[index].name,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 25,
                      ),
                      _buildGeneratedLeaveDaysContainer(),
                    ],
                  ),
                ),
              );
            }

            if (state is LeaveSettingsAndSessionYearsFetchFailure) {
              return Center(
                child: ErrorContainer(
                  errorMessage: state.errorMessage,
                  onTapRetry: () {
                    context
                        .read<LeaveSettingsAndSessionYearsCubit>()
                        .getLeaveSettingsAndSessionYears();
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
        const Align(
          alignment: Alignment.topCenter,
          child: CustomAppbar(titleKey: applyLeaveKey),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: BlocBuilder<LeaveSettingsAndSessionYearsCubit,
              LeaveSettingsAndSessionYearsState>(
            builder: (context, state) {
              if (state is LeaveSettingsAndSessionYearsFetchSuccess) {
                return SafeArea(child: _buildSubmitLeaveContainer());
              }
              return const SizedBox();
            },
          ),
        ),
      ],
    ));
  }
}
