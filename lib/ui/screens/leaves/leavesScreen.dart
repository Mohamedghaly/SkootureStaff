import 'package:eschool_saas_staff/cubits/academics/sessionYearsCubit.dart';
import 'package:eschool_saas_staff/cubits/authentication/authCubit.dart';
import 'package:eschool_saas_staff/cubits/leave/userLeavesCubit.dart';
import 'package:eschool_saas_staff/data/models/sessionYear.dart';
import 'package:eschool_saas_staff/data/models/userDetails.dart';
import 'package:eschool_saas_staff/ui/screens/leaves/widgets/appliedLeaveContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/customCircularProgressIndicator.dart';
import 'package:eschool_saas_staff/ui/widgets/errorContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/filterSelectionBottomsheet.dart';
import 'package:eschool_saas_staff/ui/widgets/appbarFilterBackgroundContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/customAppbar.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/filterButton.dart';
import 'package:eschool_saas_staff/ui/widgets/noDataContainer.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/route_manager.dart';

class LeavesScreen extends StatefulWidget {
  final bool showMyLeaves;
  final UserDetails? userDetails;
  const LeavesScreen({super.key, required this.showMyLeaves, this.userDetails});

  static Widget getRouteInstance() {
    final arguments = Get.arguments as Map<String, dynamic>;
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => SessionYearsCubit(),
        ),
        BlocProvider(
          create: (context) => UserLeavesCubit(),
        ),
      ],
      child: LeavesScreen(
        userDetails: arguments['userDetails'],
        showMyLeaves: arguments['showMyLeaves'],
      ),
    );
  }

  static Map<String, dynamic> buildArguments(
      {required bool showMyLeaves, UserDetails? userDetails}) {
    return {"showMyLeaves": showMyLeaves, "userDetails": userDetails};
  }

  @override
  State<LeavesScreen> createState() => _LeavesScreenState();
}

class _LeavesScreenState extends State<LeavesScreen> {
  SessionYear? _selectedSessionYear;
  late String _selectedMonthKey = months[(DateTime.now().month - 1)];

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      if (mounted) {
        context.read<SessionYearsCubit>().getSessionYears();
      }
    });
  }

  void changeSelectedSessionYear(SessionYear sessionYear) {
    _selectedSessionYear = sessionYear;
    setState(() {});
    getLeaves();
  }

  void changeSelectedMonth(String month) {
    _selectedMonthKey = month;
    setState(() {});
    getLeaves();
  }

  int getSelectedMonthNumber() {
    return months.indexOf(_selectedMonthKey) + 1;
  }

  void getLeaves() {
    context.read<UserLeavesCubit>().getUserLeaves(
        monthNumber: getSelectedMonthNumber(),
        userId: widget.showMyLeaves
            ? (context.read<AuthCubit>().getUserDetails().id ?? 0)
            : (widget.userDetails?.id ?? 0),
        sessionYearId: (_selectedSessionYear?.id ?? 0));
  }

  Widget _buildLeaveCountContainer(
      {required double width, required String title, required String value}) {
    return Container(
      width: width,
      height: 70,
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Theme.of(context).colorScheme.tertiary)),
      padding: EdgeInsets.symmetric(
          vertical: 10, horizontal: appContentHorizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTextContainer(
            textKey: value,
            style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          CustomTextContainer(
            textKey: title,
            style: TextStyle(
                height: 1.1,
                fontSize: 13.0,
                color: Theme.of(context)
                    .colorScheme
                    .secondary
                    .withValues(alpha: 0.76)),
          ),
        ],
      ),
    );
  }

  Widget _buildLeavesContainer() {
    return BlocBuilder<UserLeavesCubit, UserLeavesState>(
      builder: (context, state) {
        if (state is UserLeavesFetchSuccess) {
          if (state.leaves.isEmpty) {
            return Center(
              child: noDataContainer(
                titleKey: noLeavesKey,
              ),
            );
          }
          return Align(
            alignment: Alignment.topCenter,
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                  top:
                      Utils.appContentTopScrollPadding(context: context) + 100),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: appContentHorizontalPadding),
                    child: LayoutBuilder(builder: (context, boxConstraints) {
                      double remainingLeaves = (state.monthlyAllowedLeaves -
                          context.read<UserLeavesCubit>().getTakenLeavesCount(
                              monthNumber: getSelectedMonthNumber()));
                      remainingLeaves =
                          remainingLeaves < 0 ? 0 : remainingLeaves;
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildLeaveCountContainer(
                              width: boxConstraints.maxWidth * (0.48),
                              title: allowedLeavesKey,
                              value: state.monthlyAllowedLeaves
                                  .toStringAsFixed(2)),
                          _buildLeaveCountContainer(
                              width: boxConstraints.maxWidth * (0.48),
                              title: remainingLeavesKey,
                              value: remainingLeaves.toStringAsFixed(2)),
                        ],
                      );
                    }),
                  ),
                  const SizedBox(
                    height: 25,
                  ),
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
                                  width: boxConstraints.maxWidth * (0.4),
                                  child: const CustomTextContainer(
                                      textKey: leaveDateKey),
                                ),
                                SizedBox(
                                  width: boxConstraints.maxWidth * (0.45),
                                  child: const CustomTextContainer(
                                      textKey: statusKey),
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
                            children: List.generate(
                                state.leaves.length,
                                (index) => AppliedLeaveContainer(
                                    leaveRequest: state.leaves[index],
                                    index: index)).toList(),
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

        if (state is UserLeavesFetchFailure) {
          return Center(
            child: ErrorContainer(
              errorMessage: state.errorMessage,
              onTapRetry: () {
                getLeaves();
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
        BlocBuilder<SessionYearsCubit, SessionYearsState>(
          builder: (context, state) {
            if (state is SessionYearsFetchSuccess) {
              return _buildLeavesContainer();
            }

            if (state is SessionYearsFetchFailure) {
              return Center(
                child: ErrorContainer(
                  errorMessage: state.errorMessage,
                  onTapRetry: () {
                    context.read<SessionYearsCubit>().getSessionYears();
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
          child: Column(
            children: [
              CustomAppbar(
                  titleKey: widget.showMyLeaves
                      ? myLeaveKey
                      : (widget.userDetails?.fullName ?? "")),
              BlocConsumer<SessionYearsCubit, SessionYearsState>(
                listener: (context, state) {
                  if (state is SessionYearsFetchSuccess) {
                    if (state.sessionYears.isNotEmpty) {
                      changeSelectedSessionYear(state.sessionYears
                          .where((element) => element.isThisDefault())
                          .first);
                    }
                  }
                },
                builder: (context, state) {
                  return AppbarFilterBackgroundContainer(
                    child: LayoutBuilder(builder: (context, boxConstraints) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          FilterButton(
                              onTap: () {
                                if (state is SessionYearsFetchSuccess &&
                                    state.sessionYears.isNotEmpty) {
                                  Utils.showBottomSheet(
                                      child: FilterSelectionBottomsheet<
                                          SessionYear>(
                                        selectedValue: _selectedSessionYear!,
                                        titleKey: sessionYearKey,
                                        values: state.sessionYears,
                                        onSelection: (value) {
                                          changeSelectedSessionYear(value!);
                                          Get.back();
                                        },
                                      ),
                                      context: context);
                                }
                              },
                              titleKey:
                                  _selectedSessionYear?.name ?? sessionYearKey,
                              width: boxConstraints.maxWidth * (0.49)),
                          FilterButton(
                              onTap: () {
                                Utils.showBottomSheet(
                                    child: FilterSelectionBottomsheet<String>(
                                      selectedValue: _selectedMonthKey,
                                      titleKey: monthKey,
                                      values: months,
                                      onSelection: (value) {
                                        changeSelectedMonth(value!);
                                        Get.back();
                                      },
                                    ),
                                    context: context);
                              },
                              titleKey: _selectedMonthKey,
                              width: boxConstraints.maxWidth * (0.49)),
                        ],
                      );
                    }),
                  );
                },
              ),
            ],
          ),
        )
      ],
    ));
  }
}
