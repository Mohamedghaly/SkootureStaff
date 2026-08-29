import 'dart:async';
import 'package:eschool_saas_staff/cubits/staffAttendance/staffAttendanceCubit.dart';
import 'package:eschool_saas_staff/cubits/staffAttendance/submitStaffAttendanceCubit.dart';
import 'package:eschool_saas_staff/data/models/staffAttendance.dart';
import 'package:eschool_saas_staff/ui/widgets/appbarFilterBackgroundContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/customAppbar.dart';
import 'package:eschool_saas_staff/ui/widgets/customCircularProgressIndicator.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/errorContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/filterButton.dart';
import 'package:eschool_saas_staff/ui/widgets/noDataContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/searchContainer.dart';
import 'package:eschool_saas_staff/ui/screens/staffAttendance/widget/staffAttendanceContainer.dart';
import 'package:eschool_saas_staff/ui/screens/staffAttendance/widget/staffAttendanceFloatingActionBar.dart';
import 'package:eschool_saas_staff/ui/screens/staffAttendance/widget/staffAttendanceStatusBottomSheet.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class StaffAttendanceScreen extends StatefulWidget {
  static Widget getRouteInstance() {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => StaffAttendanceCubit(),
        ),
        BlocProvider(
          create: (context) => SubmitStaffAttendanceCubit(),
        ),
      ],
      child: const StaffAttendanceScreen(),
    );
  }

  static Map<String, dynamic> buildArguments({bool canEdit = true}) {
    return {'canEdit': canEdit};
  }

  const StaffAttendanceScreen({super.key});

  @override
  State<StaffAttendanceScreen> createState() => _StaffAttendanceScreenState();
}

class _StaffAttendanceScreenState extends State<StaffAttendanceScreen> {
  // Store all records with their current status
  List<StaffAttendanceRecord> allRecords = [];

  // Track selected staff IDs for multi-select
  Set<String> selectedStaffIds = {};

  DateTime _selectedDateTime = DateTime.now();
  bool _isHoliday = false;
  bool _isMarkingAsHoliday = false; // Track if we're in holiday marking mode

  /// Whether the user can edit attendance (mark/unmark/holiday)
  late final bool _canEdit;

  // Search functionality
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    final arguments = Get.arguments as Map<String, dynamic>?;
    _canEdit = arguments?['canEdit'] as bool? ?? true;
    _searchController.addListener(_searchListener);
    Future.delayed(Duration.zero, () {
      if (mounted) {
        getStaffAttendance();
      }
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_searchListener);
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _searchListener() {
    if (_searchController.text.trim().isEmpty) {
      return;
    }
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        allRecords.clear();
        selectedStaffIds.clear();
      });
      getStaffAttendance();
    });
  }

  void getStaffAttendance() {
    final dateString = DateFormat('yyyy-MM-dd').format(_selectedDateTime);
    final searchQuery = _searchController.text.trim();
    context.read<StaffAttendanceCubit>().fetchStaffAttendance(
          date: dateString,
          classSectionId: null,
          search: searchQuery.isEmpty ? null : searchQuery,
        );
  }

  /// Check if records should be refreshed based on API data
  /// Returns true if any record has different status than current allRecords
  bool _shouldRefreshRecords(List<StaffAttendanceRecord> newRecords) {
    if (allRecords.isEmpty) return true;

    for (int i = 0; i < newRecords.length; i++) {
      if (i >= allRecords.length) return true;

      final newRecord = newRecords[i];
      final oldRecord = allRecords[i];

      // Check if staff ID matches
      if (newRecord.staffId != oldRecord.staffId) return true;

      // Check if record type changed (not_marked -> already_marked or vice versa)
      if (newRecord.recordType != oldRecord.recordType) return true;

      // Check if status changed for already_marked records
      if (newRecord.recordType == 'already_marked' &&
          newRecord.currentStatus != oldRecord.currentStatus) {
        return true;
      }
    }

    return false;
  }

  void _handleStaffSelection(String staffId, bool isSelected) {
    setState(() {
      if (isSelected) {
        selectedStaffIds.add(staffId);
      } else {
        selectedStaffIds.remove(staffId);
      }
    });
  }

  void _handleSelectAll(bool selectAll) {
    setState(() {
      if (selectAll) {
        // Select all staff who can be selected (only payroll check now)
        selectedStaffIds = allRecords
            .where((record) => record.canBeSelected())
            .map((record) => record.staffId?.toString() ?? '')
            .where((id) => id.isNotEmpty)
            .toSet();
      } else {
        // Deselect all
        selectedStaffIds.clear();
      }
    });
  }

  void _handleClearSelection() {
    setState(() {
      selectedStaffIds.clear();
    });
  }

  void _handleMarkAttendance() {
    if (selectedStaffIds.isEmpty) {
      return;
    }

    // Get selected staff records
    final selectedRecords = allRecords
        .where((record) =>
            selectedStaffIds.contains(record.staffId?.toString() ?? ''))
        .toList();

    // If only one staff is selected, pre-fill their reason
    String? initialReason;
    if (selectedRecords.length == 1 && selectedRecords.first.reason != null) {
      initialReason = selectedRecords.first.reason;
    }

    // Show the status bottom sheet
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(bottomSheetContext).viewInsets.bottom,
          ),
          child: StaffAttendanceStatusBottomSheet(
            selectedStaffRecords: selectedRecords,
            initialReason: initialReason,
            onStatusSelected: (status, reason) {
              // Store the selected IDs before clearing
              final staffIdsToSubmit = Set<String>.from(selectedStaffIds);

              // Apply the status to all selected staff
              setState(() {
                allRecords = allRecords.map((record) {
                  final staffId = record.staffId?.toString() ?? '';
                  if (selectedStaffIds.contains(staffId)) {
                    return record.copyWith(
                      currentStatus: status,
                      reason: reason,
                    );
                  }
                  return record;
                }).toList();

                // Clear selection after marking
                selectedStaffIds.clear();
              });

              // Submit attendance immediately with specific staff IDs
              _submitAttendance(staffIdsToSubmit: staffIdsToSubmit);
            },
          ),
        );
      },
    );
  }

  void _handleMarkHoliday() {
    if (selectedStaffIds.isEmpty) {
      return;
    }

    // Store the selected IDs before clearing
    final staffIdsToSubmit = Set<String>.from(selectedStaffIds);

    // Apply holiday status to all selected staff
    setState(() {
      allRecords = allRecords.map((record) {
        final staffId = record.staffId?.toString() ?? '';
        if (selectedStaffIds.contains(staffId)) {
          return record.copyWith(
            currentStatus: StaffAttendanceStatus.holiday,
            reason: null, // No reason needed for holiday
          );
        }
        return record;
      }).toList();

      // Clear selection after marking
      selectedStaffIds.clear();
    });

    // Submit attendance immediately with specific staff IDs
    _submitAttendance(staffIdsToSubmit: staffIdsToSubmit);
  }

  void _submitAttendance({Set<String>? staffIdsToSubmit}) {
    // Filter records that should be submitted
    final recordsToSubmit = allRecords.where((record) {
      final staffId = record.staffId?.toString() ?? '';

      // If specific staff IDs provided, only submit those
      if (staffIdsToSubmit != null && staffIdsToSubmit.isNotEmpty) {
        return staffIdsToSubmit.contains(staffId) &&
            record.currentStatus != null &&
            record.currentStatus != StaffAttendanceStatus.notMarked;
      }

      // Otherwise, submit all marked records
      return record.currentStatus != null &&
          record.currentStatus != StaffAttendanceStatus.notMarked;
    }).toList();

    if (recordsToSubmit.isEmpty) {
      Utils.showSnackBar(
        context: context,
        message: pleaseMarkAttendanceForAtLeastOneStaffKey,
      );
      return;
    }

    // Prepare attendance data
    final List<AttendanceSubmissionData> attendanceData =
        recordsToSubmit.map((record) {
      return AttendanceSubmissionData(
        id: record.attendanceId,
        staffId: record.staffId,
        type: record.currentStatus?.typeValue ?? 1,
        reason: (record.currentStatus ==
                    StaffAttendanceStatus.absentWithReason ||
                record.currentStatus ==
                    StaffAttendanceStatus.absentWithoutReason ||
                record.currentStatus ==
                    StaffAttendanceStatus.firstHalfPresent ||
                record.currentStatus == StaffAttendanceStatus.secondHalfPresent)
            ? record.reason
            : null,
        leaveId: null,
      );
    }).toList();

    final payload = StaffAttendanceSubmissionPayload(
      date: DateFormat('yyyy-MM-dd').format(_selectedDateTime),
      holiday: _isHoliday ? true : null,
      attendanceData: attendanceData,
      absentNotification: true,
    );

    context
        .read<SubmitStaffAttendanceCubit>()
        .submitAttendance(payload: payload);
  }

  Widget _buildStaffAttendanceList() {
    return BlocBuilder<StaffAttendanceCubit, StaffAttendanceState>(
      builder: (context, state) {
        if (state is StaffAttendanceFetchSuccess) {
          // Check if the date is marked as a holiday
          if (state.attendanceResponse.isHoliday) {
            // Update the holiday checkbox state
            if (!_isHoliday) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                setState(() {
                  _isHoliday = true;
                });
              });
            }
            return Center(
              child: Padding(
                padding:
                    EdgeInsets.only(top: topPaddingOfErrorAndLoadingContainer),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.celebration,
                      size: 64,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    CustomTextContainer(
                      textKey: state.attendanceResponse.message ??
                          Utils.getTranslatedLabel(thisDateMarkedAsHolidayKey),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state.records.isEmpty) {
            return const noDataContainer(titleKey: noTeachersFoundForClassKey);
          }

          // Always update allRecords with fresh data from API
          // This ensures status labels are correctly displayed after API refresh
          if (allRecords.isEmpty ||
              allRecords.length != state.records.length ||
              _shouldRefreshRecords(state.records)) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() {
                  allRecords = state.records;
                });
              }
            });
            // Use state.records directly for initial render
            return StaffAttendanceContainer(
              staffAttendanceRecords: state.records,
              selectedStaffIds: selectedStaffIds,
              showCheckbox: _canEdit,
              onSelectionChanged: _canEdit ? _handleStaffSelection : null,
              onSelectAllChanged: _canEdit ? _handleSelectAll : null,
            );
          }

          return StaffAttendanceContainer(
            staffAttendanceRecords: allRecords,
            selectedStaffIds: selectedStaffIds,
            showCheckbox: _canEdit,
            onSelectionChanged: _canEdit ? _handleStaffSelection : null,
            onSelectAllChanged: _canEdit ? _handleSelectAll : null,
          );
        } else if (state is StaffAttendanceFetchFailure) {
          return Center(
            child: Padding(
              padding:
                  EdgeInsets.only(top: topPaddingOfErrorAndLoadingContainer),
              child: ErrorContainer(
                errorMessage: state.errorMessage,
                onTapRetry: () {
                  getStaffAttendance();
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

  Widget _buildStaffAttendanceContainer() {
    return BlocBuilder<StaffAttendanceCubit, StaffAttendanceState>(
      builder: (context, attendanceState) {
        // Adjust padding based on whether holiday checkbox is visible
        final isApiHoliday = attendanceState is StaffAttendanceFetchSuccess &&
            attendanceState.attendanceResponse.isHoliday;
        // Date filter (60) + Search field (60) + Holiday checkbox (50 if visible)
        final topPadding = isApiHoliday ? 180.0 : 230.0;

        return Align(
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              top: Utils.appContentTopScrollPadding(context: context) +
                  topPadding,
              bottom: 130,
            ),
            child: _buildStaffAttendanceList(),
          ),
        );
      },
    );
  }

  Widget _buildFloatingActionBar() {
    if (!_canEdit) return const SizedBox.shrink();
    return BlocBuilder<StaffAttendanceCubit, StaffAttendanceState>(
      builder: (context, state) {
        if (state is StaffAttendanceFetchSuccess) {
          return BlocConsumer<SubmitStaffAttendanceCubit,
              SubmitStaffAttendanceState>(
            listener: (context, submitState) {
              if (submitState is SubmitStaffAttendanceSuccess) {
                Utils.showSnackBar(
                  context: context,
                  message: Utils.getTranslatedLabel(
                    attendanceSubmittedSuccessfullyKey,
                  ),
                );
                // Clear records and selection to force fresh data load
                setState(() {
                  allRecords.clear();
                  selectedStaffIds.clear();
                });
                // Refresh attendance data
                getStaffAttendance();
              } else if (submitState is SubmitStaffAttendanceFailure) {
                Utils.showSnackBar(
                  context: context,
                  message: submitState.errorMessage,
                );
                // Revert optimistic update — re-fetch actual data from server
                setState(() {
                  allRecords.clear();
                  selectedStaffIds.clear();
                });
                getStaffAttendance();
              }
            },
            builder: (context, submitState) {
              // Show loading overlay if submitting
              if (submitState is SubmitStaffAttendanceInProgress) {
                return Container(
                  color: Colors.black.withValues(alpha: 0.3),
                  child: Center(
                    child: CustomCircularProgressIndicator(
                      indicatorColor: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                );
              }

              return SafeArea(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: selectedStaffIds.isEmpty
                      ? const SizedBox.shrink()
                      : _isMarkingAsHoliday
                          ? // Holiday mode: Show ONLY Holiday button
                          Padding(
                              padding:
                                  EdgeInsets.all(appContentHorizontalPadding),
                              child: Material(
                                color: const Color(
                                    0xFF9C27B0), // Purple for holiday
                                borderRadius: BorderRadius.circular(12),
                                elevation: 4,
                                child: InkWell(
                                  onTap: _handleMarkHoliday,
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 14,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.celebration_outlined,
                                          color: Colors.white,
                                          size: 22,
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          Utils.getTranslatedLabel(
                                              markAsHolidayKey),
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : // Regular mode: Show floating action bar
                          StaffAttendanceFloatingActionBar(
                              selectedCount: selectedStaffIds.length,
                              onMarkTap: _handleMarkAttendance,
                              onClearTap: _handleClearSelection,
                            ),
                ),
              );
            },
          );
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildAppbarAndFilters() {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CustomAppbar(titleKey: staffAttendanceKey),
            // Date Filter (larger now)
            AppbarFilterBackgroundContainer(
              child: FilterButton(
                onTap: () async {
                  final selectedDate = await Utils.openDatePicker(
                    context: context,
                    inititalDate: _selectedDateTime,
                    lastDate: DateTime.now(),
                    firstDate:
                        DateTime.now().subtract(const Duration(days: 30)),
                  );

                  if (selectedDate != null) {
                    setState(() {
                      _selectedDateTime = selectedDate;
                      _isHoliday = false;
                      _isMarkingAsHoliday = false;
                      allRecords.clear();
                      selectedStaffIds.clear();
                    });
                    getStaffAttendance();
                  }
                },
                titleKey: Utils.formatDate(_selectedDateTime),
                width: double.infinity,
              ),
            ),
            // Search Field with background to fill gaps
            Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: SearchContainer(
                textEditingController: _searchController,
                additionalCallback: () {
                  setState(() {
                    allRecords.clear();
                    selectedStaffIds.clear();
                  });
                  getStaffAttendance();
                },
                margin: EdgeInsets.symmetric(
                  horizontal: appContentHorizontalPadding,
                  vertical: 8,
                ),
              ),
            ),
            // Holiday Checkbox
            BlocBuilder<StaffAttendanceCubit, StaffAttendanceState>(
              builder: (context, attendanceState) {
                final isApiHoliday =
                    attendanceState is StaffAttendanceFetchSuccess &&
                        attendanceState.attendanceResponse.isHoliday;

                if (!isApiHoliday && _canEdit) {
                  return AppbarFilterBackgroundContainer(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () {
                            setState(() {
                              _isHoliday = !_isHoliday;
                              _isMarkingAsHoliday = !_isMarkingAsHoliday;
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
                        const SizedBox(width: 10),
                        const Expanded(
                          child: CustomTextContainer(
                            textKey: markAsHolidayKey,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildStaffAttendanceContainer(),
          _buildFloatingActionBar(),
          _buildAppbarAndFilters(),
        ],
      ),
    );
  }
}
