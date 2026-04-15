import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eschool_saas_staff/ui/widgets/customAppbar.dart';
import 'package:eschool_saas_staff/ui/widgets/customCircularProgressIndicator.dart';
import 'package:eschool_saas_staff/ui/widgets/errorContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:eschool_saas_staff/cubits/transportUserAttendance/transportUserAttendanceCubit.dart';
import 'package:eschool_saas_staff/cubits/authentication/authCubit.dart';
import 'package:eschool_saas_staff/data/models/transportUserAttendance.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  static Widget getRouteInstance() => BlocProvider(
        create: (context) => TransportUserAttendanceCubit(),
        child: const AttendanceScreen(),
      );

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() {
    final userId = context.read<AuthCubit>().getUserDetails().id ?? 0;
    if (userId > 0) {
      context
          .read<TransportUserAttendanceCubit>()
          .fetchAttendance(userId: userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          CustomAppbar(
            titleKey: Utils.getTranslatedLabel(transportationAttendanceKey),
            showBackButton: true,
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final bool isTablet = constraints.maxWidth > 600;
                final double horizontalPadding = isTablet
                    ? appContentHorizontalPadding * 1.5
                    : appContentHorizontalPadding;

                return Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: 16,
                  ),
                  child: BlocBuilder<TransportUserAttendanceCubit,
                      TransportUserAttendanceState>(
                    builder: (context, state) {
                      return RefreshIndicator(
                        onRefresh: () async {
                          final userId =
                              context.read<AuthCubit>().getUserDetails().id ??
                                  0;
                          if (userId > 0) {
                            await context
                                .read<TransportUserAttendanceCubit>()
                                .refresh(userId);
                          }
                        },
                        child: _buildContentWithFilters(state, constraints),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentWithFilters(
      TransportUserAttendanceState state, BoxConstraints constraints) {
    final cubit = context.read<TransportUserAttendanceCubit>();
    final bool isWide = constraints.maxWidth > 460;
    final double contentGap = isWide ? 20.0 : 16.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Filters - Always visible at top
        _buildFilters(cubit, constraints),
        SizedBox(height: contentGap),

        // Content area - handles different states
        Expanded(
          child: _buildMainContent(state, constraints),
        ),
      ],
    );
  }

  Widget _buildMainContent(
      TransportUserAttendanceState state, BoxConstraints constraints) {
    final bool isWide = constraints.maxWidth > 460;
    final double contentGap = isWide ? 20.0 : 16.0;

    if (state is TransportUserAttendanceLoading) {
      return Center(
        child: CustomCircularProgressIndicator(
          indicatorColor: Theme.of(context).colorScheme.primary,
        ),
      );
    }

    if (state is TransportUserAttendanceError) {
      return Center(
        child: ErrorContainer(
          errorMessage: state.message,
          onTapRetry: _loadInitialData,
        ),
      );
    }

    // For loaded state and initial state
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (state is TransportUserAttendanceLoaded) ...[
            if (state.data.hasData) ...[
              _buildSummaryCard(state.data.summary, constraints),
              SizedBox(height: contentGap),
              _buildAttendanceTable(state.data.records, constraints),
            ] else
              _buildEmptyState(constraints),
          ] else
            _buildEmptyState(constraints),

          // Add some bottom padding
          SizedBox(height: contentGap + 4),
        ],
      ),
    );
  }

  Widget _buildFilters(
      TransportUserAttendanceCubit cubit, BoxConstraints constraints) {
    final bool isWide = constraints.maxWidth > 460;
    final double filterGap = isWide ? 16.0 : 12.0;

    return Row(
      children: [
        Expanded(
          child: _buildDropdown(
            label: cubit.getCurrentMonthLabel(),
            options: cubit.monthOptions,
            onSelected: (option) {
              final userId = context.read<AuthCubit>().getUserDetails().id ?? 0;
              cubit.updateFilters(userId: userId, month: option.value);
            },
            constraints: constraints,
          ),
        ),
        SizedBox(width: filterGap),
        Expanded(
          child: _buildDropdown(
            label: cubit.getCurrentTripTypeLabel(),
            options: cubit.tripTypeOptions,
            onSelected: (option) {
              final userId = context.read<AuthCubit>().getUserDetails().id ?? 0;
              cubit.updateFilters(userId: userId, tripType: option.value);
            },
            constraints: constraints,
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required List<FilterOption> options,
    required Function(FilterOption) onSelected,
    required BoxConstraints constraints,
  }) {
    final bool isWide = constraints.maxWidth > 460;
    final double dropdownHeight = isWide ? 48.0 : 44.0;
    final double fontSize = isWide ? 15.0 : 14.0;
    final double horizontalPadding = isWide ? 16.0 : 12.0;

    return GestureDetector(
      onTap: () => _showDropdownMenu(options, onSelected),
      child: Container(
        height: dropdownHeight,
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Theme.of(context).colorScheme.tertiary),
        ),
        child: Row(
          children: [
            Expanded(
              child: CustomTextContainer(
                textKey: label,
                style:
                    TextStyle(fontSize: fontSize, fontWeight: FontWeight.w600),
              ),
            ),
            const Icon(Icons.expand_more),
          ],
        ),
      ),
    );
  }

  void _showDropdownMenu(
      List<FilterOption> options, Function(FilterOption) onSelected) {
    // Calculate dynamic height based on content
    final double itemHeight = 56.0; // Standard ListTile height
    final double handleHeight = 28.0; // Handle bar + margins
    final double padding = 16.0; // Bottom padding
    final double maxScreenHeight = MediaQuery.of(context).size.height;
    final double calculatedHeight =
        handleHeight + (options.length * itemHeight) + padding;
    final double finalHeight =
        calculatedHeight.clamp(200.0, maxScreenHeight * 0.6);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      isScrollControlled: true,
      builder: (context) => Container(
        height: finalHeight,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Options list
            Expanded(
              child: ListView.builder(
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final option = options[index];
                  return ListTile(
                    title: CustomTextContainer(
                      textKey: option.label,
                      style: const TextStyle(fontSize: 16),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      onSelected(option);
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 16), // Bottom padding
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
      AttendanceSummary summary, BoxConstraints constraints) {
    final bool isWide = constraints.maxWidth > 460;
    final double cardPadding = isWide ? 20.0 : 16.0;
    final double titleSize = isWide ? 18.0 : 16.0;
    final double itemGap = isWide ? 16.0 : 12.0;

    return Container(
      padding: EdgeInsets.all(cardPadding),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.tertiary),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTextContainer(
            textKey: Utils.getTranslatedLabel(attendanceSummaryKey),
            style: TextStyle(fontSize: titleSize, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: itemGap),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  Utils.getTranslatedLabel(totalKey),
                  summary.totalDays.toString(),
                  Colors.blue,
                  constraints,
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  Utils.getTranslatedLabel(presentKey),
                  summary.present.toString(),
                  Colors.green,
                  constraints,
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  Utils.getTranslatedLabel(absentKey),
                  summary.absent.toString(),
                  Colors.red,
                  constraints,
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  Utils.getTranslatedLabel(percentageKey),
                  '${summary.attendancePercentage.toStringAsFixed(1)}%',
                  summary.attendancePercentage >= 75
                      ? Colors.green
                      : Colors.orange,
                  constraints,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
      String label, String value, Color color, BoxConstraints constraints) {
    final bool isWide = constraints.maxWidth > 460;
    final double valueSize = isWide ? 22.0 : 20.0;
    final double labelSize = isWide ? 13.0 : 12.0;
    final double itemGap = isWide ? 6.0 : 4.0;

    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: valueSize,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        SizedBox(height: itemGap),
        Text(
          label,
          style: TextStyle(
              fontSize: labelSize,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.6)),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildAttendanceTable(
      List<AttendanceRecord> records, BoxConstraints constraints) {
    final bool isWide = constraints.maxWidth > 460;
    final double tablePadding = isWide ? 20.0 : 16.0;
    final double verticalPadding = isWide ? 16.0 : 14.0;
    final double horizontalGap = isWide ? 20.0 : 16.0;
    final double headerFontSize = isWide ? 15.0 : 14.0;
    final double contentFontSize = isWide ? 14.0 : 13.0;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.tertiary),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.symmetric(
                horizontal: tablePadding, vertical: verticalPadding),
            decoration: BoxDecoration(
              color: const Color(0xFFE9EDF3),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: isWide ? 32 : 24,
                  child: CustomTextContainer(
                    textKey: '#',
                    style: TextStyle(
                        fontWeight: FontWeight.w700, fontSize: headerFontSize),
                  ),
                ),
                SizedBox(width: horizontalGap),
                Expanded(
                  flex: 2,
                  child: CustomTextContainer(
                    textKey: Utils.getTranslatedLabel(dateKey),
                    style: TextStyle(
                        fontWeight: FontWeight.w700, fontSize: headerFontSize),
                  ),
                ),
                Expanded(
                  child: CustomTextContainer(
                    textKey: Utils.getTranslatedLabel(tripKey),
                    style: TextStyle(
                        fontWeight: FontWeight.w700, fontSize: headerFontSize),
                  ),
                ),
                Expanded(
                  child: CustomTextContainer(
                    textKey: Utils.getTranslatedLabel(statusKey),
                    style: TextStyle(
                        fontWeight: FontWeight.w700, fontSize: headerFontSize),
                  ),
                ),
              ],
            ),
          ),
          // Records
          ...records.asMap().entries.map((entry) {
            final index = entry.key + 1;
            final record = entry.value;
            return Container(
              padding: EdgeInsets.symmetric(
                  horizontal: tablePadding, vertical: verticalPadding),
              decoration: BoxDecoration(
                border: Border(
                  top:
                      BorderSide(color: Theme.of(context).colorScheme.tertiary),
                ),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: isWide ? 32 : 24,
                    child: CustomTextContainer(
                      textKey: '$index',
                      style: TextStyle(fontSize: contentFontSize),
                    ),
                  ),
                  SizedBox(width: horizontalGap),
                  Expanded(
                    flex: 2,
                    child: CustomTextContainer(
                      textKey: _formatDate(record.date),
                      style: TextStyle(
                          fontSize: contentFontSize,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                  Expanded(
                    child: CustomTextContainer(
                      textKey: record.tripTypeDisplay,
                      style: TextStyle(fontSize: contentFontSize - 1),
                    ),
                  ),
                  Expanded(
                    child: _buildStatusChip(record.status),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color bgColor;
    Color textColor;
    String displayText;

    switch (status.toUpperCase()) {
      case 'P':
        bgColor =
            const Color(0xFFE8F5E8); // Light green background like in image
        textColor = const Color(0xFF2E7D32); // Dark green text
        displayText = 'P';
        break;
      case 'A':
        bgColor = const Color(0xFFFFEBEE); // Light red background like in image
        textColor = const Color(0xFFC62828); // Dark red text
        displayText = 'A';
        break;
      default:
        bgColor = const Color(0xFFF5F5F5); // Light grey background
        textColor = const Color(0xFF757575); // Dark grey text
        displayText = '?';
    }

    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius:
              BorderRadius.circular(4), // Small radius, rectangular shape
        ),
        child: Text(
          displayText,
          style: TextStyle(
            color: textColor,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildEmptyState(BoxConstraints constraints) {
    final bool isWide = constraints.maxWidth > 460;
    final double iconSize = isWide ? 72.0 : 64.0;
    final double titleSize = isWide ? 18.0 : 16.0;
    final double subtitleSize = isWide ? 15.0 : 14.0;
    final double containerPadding = isWide ? 40.0 : 32.0;
    final double verticalGap = isWide ? 20.0 : 16.0;
    final double bottomSpace = isWide ? 120.0 : 100.0;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(containerPadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy,
            size: iconSize,
            color:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
          ),
          SizedBox(height: verticalGap),
          CustomTextContainer(
            textKey: Utils.getTranslatedLabel(noAttendanceRecordsFoundKey),
            style: TextStyle(
              fontSize: titleSize,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.6),
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: verticalGap * 0.5),
          CustomTextContainer(
            textKey: Utils.getTranslatedLabel(trySelectingDifferentFiltersKey),
            style: TextStyle(
              fontSize: subtitleSize,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.5),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: bottomSpace), // Extra space to center better
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ];
      return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}
