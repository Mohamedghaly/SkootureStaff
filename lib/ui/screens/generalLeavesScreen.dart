import 'package:eschool_saas_staff/cubits/leave/generalLeavesCubit.dart';
import 'package:eschool_saas_staff/ui/widgets/customAppbar.dart';
import 'package:eschool_saas_staff/ui/widgets/customCircularProgressIndicator.dart';
import 'package:eschool_saas_staff/ui/widgets/customTabContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/errorContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/leaveDetailsContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/noDataContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/tabBackgroundContainer.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GeneralLeavesScreen extends StatefulWidget {
  const GeneralLeavesScreen({super.key});

  static Widget getRouteInstance() => BlocProvider(
        create: (context) => GeneralLeavesCubit(),
        child: const GeneralLeavesScreen(),
      );

  @override
  State<GeneralLeavesScreen> createState() => _GeneralLeavesScreenState();
}

class _GeneralLeavesScreenState extends State<GeneralLeavesScreen> {
  late String _selectedTabTitleKey = todayKey;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      getLeaves();
    });
  }

  void getLeaves() {
    LeaveDayType leaveDayType = LeaveDayType.today;

    if (_selectedTabTitleKey == tomorrowKey) {
      leaveDayType = LeaveDayType.tomorrow;
    } else if (_selectedTabTitleKey == upcomingKey) {
      leaveDayType = LeaveDayType.upcoming;
    }

    context
        .read<GeneralLeavesCubit>()
        .getGeneralLeaves(leaveDayType: leaveDayType);
  }

  void changeTab(String value) {
    setState(() {
      _selectedTabTitleKey = value;
    });
    getLeaves();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: BlocBuilder<GeneralLeavesCubit, GeneralLeavesState>(
              builder: (context, state) {
                if (state is GeneralLeavesFetchSuccess) {
                  if (state.leaves.isEmpty) {
                    return Center(
                      child: noDataContainer(
                        titleKey: noLeavesTodayKey,
                      ),
                    );
                  }
                  return SingleChildScrollView(
                    padding: EdgeInsets.only(
                        top:
                            Utils.appContentTopScrollPadding(context: context) +
                                100),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.symmetric(
                          vertical: appContentHorizontalPadding),
                      color: Theme.of(context).colorScheme.surface,
                      child: Column(
                        children: state.leaves
                            .map((leaveDetails) => LeaveDetailsContainer(
                                leaveDetails: leaveDetails))
                            .toList(),
                      ),
                    ),
                  );
                }

                if (state is GeneralLeavesFetchFailure) {
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
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CustomAppbar(titleKey: leavesKey),
                TabBackgroundContainer(
                    child: LayoutBuilder(builder: (context, boxConstraints) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomTabContainer(
                          titleKey: todayKey,
                          isSelected: todayKey == _selectedTabTitleKey,
                          width: boxConstraints.maxWidth * (0.31),
                          onTap: changeTab),
                      CustomTabContainer(
                          titleKey: tomorrowKey,
                          isSelected: tomorrowKey == _selectedTabTitleKey,
                          width: boxConstraints.maxWidth * (0.31),
                          onTap: changeTab),
                      CustomTabContainer(
                          titleKey: upcomingKey,
                          isSelected: upcomingKey == _selectedTabTitleKey,
                          width: boxConstraints.maxWidth * (0.31),
                          onTap: changeTab),
                    ],
                  );
                }))
              ],
            ),
          )
        ],
      ),
    );
  }
}
