import 'dart:async';

import 'package:eschool_saas_staff/app/routes.dart';
import 'package:eschool_saas_staff/cubits/staff/staffsCubit.dart';
import 'package:eschool_saas_staff/ui/screens/leaves/leavesScreen.dart';
import 'package:eschool_saas_staff/ui/screens/staffDetailsScreen.dart';
import 'package:eschool_saas_staff/ui/widgets/customAppbar.dart';
import 'package:eschool_saas_staff/ui/widgets/customCircularProgressIndicator.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/errorContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/noDataContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/profileImageContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/searchContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/tabBackgroundContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/customTabContainer.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/route_manager.dart';

class StaffsScreen extends StatefulWidget {
  final bool forStaffLeave;
  const StaffsScreen({super.key, required this.forStaffLeave});

  static Widget getRouteInstance() {
    final arguments = Get.arguments as Map<String, dynamic>;
    return BlocProvider(
      create: (context) => StaffsCubit(),
      child: StaffsScreen(
        forStaffLeave: arguments['forStaffLeave'],
      ),
    );
  }

  static Map<String, dynamic> buildArguments({required bool forStaffLeave}) {
    return {"forStaffLeave": forStaffLeave};
  }

  @override
  State<StaffsScreen> createState() => _StaffsScreenState();
}

class _StaffsScreenState extends State<StaffsScreen> {
  late String _selectedTabKey = allKey;
  late final TextEditingController _textEditingController =
      TextEditingController()..addListener(searchQueryTextControllerListener);

  late int waitForNextRequestSearchQueryTimeInMilliSeconds =
      nextSearchRequestQueryTimeInMilliSeconds;

  Timer? waitForNextSearchRequestTimer;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      getStaffs();
    });
  }

  @override
  void dispose() {
    waitForNextSearchRequestTimer?.cancel();
    _textEditingController.removeListener(searchQueryTextControllerListener);
    _textEditingController.dispose();
    super.dispose();
  }

  void searchQueryTextControllerListener() {
    if (_textEditingController.text.trim().isEmpty) {
      return;
    }
    waitForNextSearchRequestTimer?.cancel();
    setWaitForNextSearchRequestTimer();
  }

  void setWaitForNextSearchRequestTimer() {
    if (waitForNextRequestSearchQueryTimeInMilliSeconds !=
        (waitForNextRequestSearchQueryTimeInMilliSeconds -
            searchRequestPerodicMilliSeconds)) {
      //
      waitForNextRequestSearchQueryTimeInMilliSeconds =
          (nextSearchRequestQueryTimeInMilliSeconds -
              searchRequestPerodicMilliSeconds);
    }
    //
    waitForNextSearchRequestTimer = Timer.periodic(
        Duration(milliseconds: searchRequestPerodicMilliSeconds), (timer) {
      if (waitForNextRequestSearchQueryTimeInMilliSeconds == 0) {
        timer.cancel();
        getStaffs();
      } else {
        waitForNextRequestSearchQueryTimeInMilliSeconds =
            waitForNextRequestSearchQueryTimeInMilliSeconds -
                searchRequestPerodicMilliSeconds;
      }
    });
  }

  void getStaffs() {
    context.read<StaffsCubit>().getStaffs(
        search: _textEditingController.text.trim().isEmpty
            ? null
            : _textEditingController.text.trim(),
        status: getSatusValueFromKey(value: _selectedTabKey));
  }

  void changeTab(String value) {
    setState(() {
      _selectedTabKey = value;
    });
    getStaffs();
  }

  Widget _buildTabContainer() {
    return TabBackgroundContainer(
      child: LayoutBuilder(builder: (context, boxConstraints) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CustomTabContainer(
                titleKey: allKey,
                isSelected: _selectedTabKey == allKey,
                width: boxConstraints.maxWidth * (0.31),
                onTap: changeTab),
            CustomTabContainer(
                titleKey: activeKey,
                isSelected: _selectedTabKey == activeKey,
                width: boxConstraints.maxWidth * (0.31),
                onTap: changeTab),
            CustomTabContainer(
                titleKey: inactiveKey,
                isSelected: _selectedTabKey == inactiveKey,
                width: boxConstraints.maxWidth * (0.31),
                onTap: changeTab),
          ],
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [
        Align(
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
                top: Utils.appContentTopScrollPadding(context: context) + 100),
            child: Column(
              children: [
                SearchContainer(
                  textEditingController: _textEditingController,
                  additionalCallback: () {
                    getStaffs();
                  },
                ),
                const SizedBox(
                  height: 25,
                ),
                BlocBuilder<StaffsCubit, StaffsState>(
                  builder: (context, state) {
                    if (state is StaffsFetchSuccess) {
                      if (state.saffs.isEmpty) {
                        return Center(
                          child: noDataContainer(
                            titleKey: noStaffsKey,
                          ),
                        );
                      }
                      return Container(
                        width: MediaQuery.of(context).size.width,
                        padding: EdgeInsets.all(appContentHorizontalPadding),
                        color: Theme.of(context).colorScheme.surface,
                        child:
                            LayoutBuilder(builder: (context, boxConstraints) {
                          return Wrap(
                            spacing: boxConstraints.maxWidth * (0.04),
                            runSpacing: 15,
                            children:
                                List.generate(state.saffs.length, (index) {
                              final staffDetails = state.saffs[index];

                              return Container(
                                height: 200,
                                padding: const EdgeInsets.all(15),
                                width: boxConstraints.maxWidth * (0.48),
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .tertiary),
                                    borderRadius: BorderRadius.circular(8)),
                                child: Column(
                                  children: [
                                    ProfileImageContainer(
                                      imageUrl: staffDetails.image ?? "",
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 15.0),
                                      child: CustomTextContainer(
                                        textKey: staffDetails.fullName ?? "-",
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                    CustomTextContainer(
                                      textKey: staffDetails.getRoles(),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary
                                              .withValues(alpha: 0.76)),
                                    ),
                                    const Spacer(),
                                    GestureDetector(
                                      onTap: () {
                                        if (widget.forStaffLeave) {
                                          Get.toNamed(Routes.leavesScreen,
                                              arguments:
                                                  LeavesScreen.buildArguments(
                                                      userDetails: staffDetails,
                                                      showMyLeaves: false));
                                        } else {
                                          Get.toNamed(Routes.staffDetailsScreen,
                                              arguments: StaffDetailsScreen
                                                  .buildArguments(
                                                      staffDetails:
                                                          staffDetails));
                                        }
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10),
                                        width: double.maxFinite,
                                        height: 35,
                                        decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .scaffoldBackgroundColor,
                                            borderRadius:
                                                BorderRadius.circular(15)),
                                        child: Row(
                                          children: [
                                            CustomTextContainer(
                                              textKey: widget.forStaffLeave
                                                  ? viewLeavesKey
                                                  : viewProfileKey,
                                              style: TextStyle(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .primary,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                            const Spacer(),
                                            Icon(
                                              Directionality.of(context).name ==
                                                      TextDirection.rtl.name
                                                  ? CupertinoIcons.arrow_left
                                                  : CupertinoIcons.arrow_right,
                                              size: 17.5,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          );
                        }),
                      );
                    }

                    if (state is StaffsFetchFailure) {
                      return Center(
                        child: Padding(
                          padding: EdgeInsets.only(
                              top: topPaddingOfErrorAndLoadingContainer),
                          child: ErrorContainer(
                            errorMessage: state.errorMessage,
                            onTapRetry: () {
                              getStaffs();
                            },
                          ),
                        ),
                      );
                    }

                    return Center(
                      child: Padding(
                        padding: EdgeInsets.only(
                            top: topPaddingOfErrorAndLoadingContainer),
                        child: CustomCircularProgressIndicator(
                          indicatorColor: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(
                  height: 25,
                ),
              ],
            ),
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: Column(
            children: [
              const CustomAppbar(titleKey: staffsKey),
              _buildTabContainer()
            ],
          ),
        ),
      ],
    ));
  }
}
