import 'package:eschool_saas_staff/app/routes.dart';
import 'package:eschool_saas_staff/cubits/announcement/notificationsCubit.dart';
import 'package:eschool_saas_staff/cubits/userDetails/staffAllowedPermissionsAndModulesCubit.dart';
import 'package:eschool_saas_staff/ui/screens/manageNotification/widgets/adminNotificationDetailsContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/customAppbar.dart';
import 'package:eschool_saas_staff/ui/widgets/customCircularProgressIndicator.dart';
import 'package:eschool_saas_staff/ui/widgets/customRoundedButton.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextButton.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/errorContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/noDataContainer.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/systemModulesAndPermissions.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/route_manager.dart';

class ManageNotificationScreen extends StatefulWidget {
  const ManageNotificationScreen({super.key});

  static Widget getRouteInstance() {
    //final arguments = Get.arguments as Map<String,dynamic>;
    return BlocProvider(
      create: (context) => NotificationsCubit(),
      child: ManageNotificationScreen(
        key: screenKey,
      ),
    );
  }

  static GlobalKey<ManageNotificationScreenState> screenKey =
      GlobalKey<ManageNotificationScreenState>();

  static Map<String, dynamic> buildArguments() {
    return {};
  }

  @override
  State<ManageNotificationScreen> createState() =>
      ManageNotificationScreenState();
}

class ManageNotificationScreenState extends State<ManageNotificationScreen> {
  late final ScrollController _scrollController = ScrollController()
    ..addListener(scrollListener);

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      getNotifications();
    });
  }

  void getNotifications() {
    context.read<NotificationsCubit>().getNotifications();
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
      if (context.read<NotificationsCubit>().hasMore()) {
        context.read<NotificationsCubit>().fetchMore();
      }
    }
  }

  Widget _buildAddNotificationButton() {
    return context
            .read<StaffAllowedPermissionsAndModulesCubit>()
            .isPermissionGiven(permission: createNotificationPermissionKey)
        ? BlocBuilder<NotificationsCubit, NotificationsState>(
            builder: (context, state) {
              if (state is NotificationsFetchSuccess) {
                return Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      padding: EdgeInsets.all(appContentHorizontalPadding),
                      decoration: BoxDecoration(boxShadow: const [
                        BoxShadow(
                            color: Colors.black12,
                            blurRadius: 1,
                            spreadRadius: 1)
                      ], color: Theme.of(context).colorScheme.surface),
                      width: MediaQuery.of(context).size.width,
                      height: 70,
                      child: CustomRoundedButton(
                        height: 40,
                        widthPercentage: 1.0,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        buttonTitle: addNotificationKey,
                        showBorder: false,
                        onTap: () {
                          Get.toNamed(Routes.addNotificationScreen);
                        },
                      ),
                    ));
              }

              return const SizedBox();
            },
          )
        : const SizedBox();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [
        BlocBuilder<NotificationsCubit, NotificationsState>(
          builder: (context, state) {
            if (state is NotificationsFetchSuccess) {
              if (state.notifications.length == 0) {
                return Center(
                  child: noDataContainer(
                    titleKey: noNotificationsKey,
                  ),
                );
              }
              return Align(
                alignment: Alignment.topCenter,
                child: RefreshIndicator(
                  onRefresh: () async {
                    getNotifications();
                  },
                  displacement:
                      Utils.appContentTopScrollPadding(context: context) + 25,
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    padding: EdgeInsets.only(
                        bottom: 100,
                        top:
                            Utils.appContentTopScrollPadding(context: context) +
                                25),
                    child: Container(
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
                            child: LayoutBuilder(
                                builder: (context, boxConstraints) {
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
                              children: List.generate(
                                  state.notifications.length, (index) {
                                if (context
                                    .read<NotificationsCubit>()
                                    .hasMore()) {
                                  if (index == state.notifications.length - 1) {
                                    if (state.fetchMoreError) {
                                      return Center(
                                        child: CustomTextButton(
                                            buttonTextKey: retryKey,
                                            onTapButton: () {
                                              context
                                                  .read<NotificationsCubit>()
                                                  .fetchMore();
                                            }),
                                      );
                                    }
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 10.0),
                                      child: Center(
                                        child: CustomCircularProgressIndicator(
                                          indicatorColor: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        ),
                                      ),
                                    );
                                  }
                                }
                                return AdminNotificationDetailsContainer(
                                    notificationDetails:
                                        state.notifications[index],
                                    index: index);
                              }).toList(),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }

            if (state is NotificationsFetchFailure) {
              return Center(
                child: ErrorContainer(
                  errorMessage: state.errorMessage,
                  onTapRetry: () {
                    getNotifications();
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
        _buildAddNotificationButton(),
        const Align(
          alignment: Alignment.topCenter,
          child: CustomAppbar(titleKey: manageNotificationKey),
        ),
      ],
    ));
  }
}
