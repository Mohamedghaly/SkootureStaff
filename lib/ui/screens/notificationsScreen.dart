import 'package:eschool_saas_staff/cubits/announcement/localNotificationsCubit.dart';
import 'package:eschool_saas_staff/ui/widgets/customAppbar.dart';
import 'package:eschool_saas_staff/ui/widgets/errorContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/noDataContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/notificationItemContainer.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../widgets/customCircularProgressIndicator.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  static Widget getRouteInstance() {
    //final arguments = Get.arguments as Map<String,dynamic>;
    return BlocProvider(
      create: (context) => LocalNotificationsCubit(),
      child: const NotificationsScreen(),
    );
  }

  static Map<String, dynamic> buildArguments() {
    return {};
  }

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      context.read<LocalNotificationsCubit>().getLocalNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [
        Align(
          alignment: Alignment.topCenter,
          child: BlocBuilder<LocalNotificationsCubit, LocalNotificationsState>(
            builder: (context, state) {
              if (state is LocalNotificationsFetchSuccess) {
                if (state.notifications.isEmpty) {
                  return Center(
                    child: noDataContainer(
                      titleKey: noNotificationsKey,
                    ),
                  );
                }
                return SingleChildScrollView(
                  padding: EdgeInsets.only(
                    top:
                        Utils.appContentTopScrollPadding(context: context) + 25,
                  ),
                  child: Column(
                    children: state.notifications
                        .map((notificationDetails) => NotificationItemContainer(
                              notificationDetails: notificationDetails,
                            ))
                        .toList(),
                  ),
                );
              }

              if (state is LocalNotificationsFetchFailure) {
                return Center(
                  child: ErrorContainer(
                    errorMessage: state.errorMessage,
                    onTapRetry: () {
                      context
                          .read<LocalNotificationsCubit>()
                          .getLocalNotifications();
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
        const Align(
          alignment: Alignment.topCenter,
          child: CustomAppbar(titleKey: notificationsKey),
        ),
      ],
    ));
  }
}
