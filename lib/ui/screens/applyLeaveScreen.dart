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
    _leaveDays = {};
    int differenceInDays =
        _selectedToDate!.difference(_selectedFromDate!).inDays;
    _leaveDays.addAll({
      _selectedFromDate!: fullDayKey,
    });
    for (var i = 1; i < differenceInDays; i++) {
      final date = _selectedFromDate!.add(Duration(days: i));

      _leaveDays.addAll({date: fullDayKey});
    }

    _leaveDays.addAll({
      _selectedToDate!: fullDayKey,
    });

    _leaveDays
        .removeWhere((key, value) => holidayWeekdays.contains(key.weekday));
  }

  void onTapFromDate() async {
    final selectedDate = await showDatePicker(
        context: context,
        firstDate: DateTime.now(),
        lastDate: DateTime.parse(context
            .read<LeaveSettingsAndSessionYearsCubit>()
            .getCurrentSessionYear()
            .endDate!));
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
      final selectedDate = await showDatePicker(
          context: context,
          firstDate: _selectedFromDate!,
          lastDate: DateTime.parse(context
              .read<LeaveSettingsAndSessionYearsCubit>()
              .getCurrentSessionYear()
              .endDate!));
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

    return Container(
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.only(
          bottom: 20.0,
          left: appContentHorizontalPadding,
          right: appContentHorizontalPadding),
      padding: EdgeInsets.all(appContentHorizontalPadding),
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(8)),
      child: LayoutBuilder(builder: (context, boxConstraints) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextWithFadedBackgroundContainer(
                backgroundColor: Theme.of(context)
                    .extension<CustomColors>()!
                    .totalStaffOverviewBackgroundColor!
                    .withValues(alpha: 0.1),
                textColor: Theme.of(context)
                    .extension<CustomColors>()!
                    .totalStaffOverviewBackgroundColor!,
                titleKey:
                    "${Utils.formatDate(dateTime)} (${Utils.weekDays[dateTime.weekday - 1].tr})"),
            const SizedBox(
              height: 15.0,
            ),
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
                                                "(${Utils.formatDate(_selectedFromDate!)})")
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
                                                "(${Utils.formatDate(_selectedToDate!)})")
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
