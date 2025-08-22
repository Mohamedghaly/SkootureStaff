import 'package:eschool_saas_staff/cubits/appConfigurationCubit.dart';
import 'package:eschool_saas_staff/cubits/authentication/authCubit.dart';
import 'package:eschool_saas_staff/cubits/chat/chatParentsUserChatHistoryCubit.dart';
import 'package:eschool_saas_staff/cubits/chat/chatStaffsUserChatHistoryCubit.dart';
import 'package:eschool_saas_staff/cubits/chat/chatStudentsUserChatHistoryCubit.dart';
import 'package:eschool_saas_staff/cubits/chat/socketSettingsCubit.dart';
import 'package:eschool_saas_staff/cubits/homeScreenDataCubit.dart';
import 'package:eschool_saas_staff/cubits/userDetails/staffAllowedPermissionsAndModulesCubit.dart';
import 'package:eschool_saas_staff/data/models/bottomNavItem.dart';
import 'package:eschool_saas_staff/data/models/notificationDetails.dart';
import 'package:eschool_saas_staff/data/repositories/announcementRepository.dart';
import 'package:eschool_saas_staff/ui/screens/home/widgets/academicsContainer/academicsContainer.dart';
import 'package:eschool_saas_staff/ui/screens/home/widgets/appUnderMaintenanceContainer.dart';
import 'package:eschool_saas_staff/ui/screens/home/widgets/chatContainer/chatContainer.dart';
import 'package:eschool_saas_staff/ui/screens/home/widgets/forceUpdateDialogContainer.dart';
import 'package:eschool_saas_staff/ui/screens/home/widgets/homeContainer/homeContainer.dart';
import 'package:eschool_saas_staff/ui/screens/home/widgets/profileContainer.dart';
import 'package:eschool_saas_staff/ui/screens/home/widgets/teacherHomeContainer/teacherHomeContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/bottomNavItemContainer.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/notificationUtility.dart';
import 'package:eschool_saas_staff/utils/systemModulesAndPermissions.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static Widget getRouteInstance() => BlocProvider(
        create: (context) => HomeScreenDataCubit(),
        child: const HomeScreen(),
      );

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  int _currentSelectedBottomNavIndex = 0;
  var canPop = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    loadTemporarilyStoredNotifications();
    Future.delayed(Duration.zero, () {
      if (mounted) {
        NotificationUtility.setUpNotificationService();
        context
            .read<StaffAllowedPermissionsAndModulesCubit>()
            .getPermissionAndAllowedModules();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void loadTemporarilyStoredNotifications() {
    AnnouncementRepository.getTemporarilyStoredNotifications()
        .then((notifications) {
      for (var notificationData in notifications) {
        AnnouncementRepository.addNotification(
            notificationDetails:
                NotificationDetails.fromJson(Map.from(notificationData)));
      }

      if (notifications.isNotEmpty) {
        AnnouncementRepository.clearTemporarilyNotification();
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      loadTemporarilyStoredNotifications();
    }
  }

  late final List<BottomNavItem> _bottomNavItems = [
    BottomNavItem(
        iconPath: "home.svg",
        title: homeKey,
        selectedIconPath: "home_active.svg"),
    BottomNavItem(
        iconPath: "academics.svg",
        title: academicsKey,
        selectedIconPath: "academics_active.svg"),
    BottomNavItem(
        iconPath: "chat.svg",
        title: chatKey,
        selectedIconPath: "chat_active.svg"),
    BottomNavItem(
        iconPath: "profile.svg",
        title: profileKey,
        selectedIconPath: "profile_active.svg"),
  ];

  void changeCurrentBottomNavIndex(int index) {
    setState(() {
      _currentSelectedBottomNavIndex = index;
    });
  }

  Widget _buildBottomNavigationContainer() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 80 + MediaQuery.of(context).padding.bottom * (0.5),
        padding: const EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          boxShadow: const [
            BoxShadow(
                color: Colors.black12,
                offset: Offset(0, 0),
                blurRadius: 1,
                spreadRadius: 1)
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(_bottomNavItems.length, (index) => index)
              .map((index) => BottomNavItemContainer(
                  index: index,
                  bottomNavItem: _bottomNavItems[index],
                  onTap: changeCurrentBottomNavIndex,
                  selectedBottomNavIndex: _currentSelectedBottomNavIndex))
              .toList(),
        ),
      ),
    );
  }

  void _onWillPop() {
    setState(() {
      canPop = true;
    });
    Utils.showSnackBar(
      message: pressbackagaintoexitKey,
      context: context,
    ); // Do not exit the app
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        canPop = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: canPop,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;

        _onWillPop();
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: context.read<AppConfigurationCubit>().appUnderMaintenance()
            ? const AppUnderMaintenanceContainer()
            : SafeArea(
                child: BlocConsumer<StaffAllowedPermissionsAndModulesCubit,
                    StaffAllowedPermissionsAndModulesState>(
                  listener: (context, state) {
                    if (state
                        is StaffAllowedPermissionsAndModulesFetchSuccess) {
                      final chatModuleEnabled = context
                          .read<StaffAllowedPermissionsAndModulesCubit>()
                          .isModuleEnabled(moduleId: chatModuleId.toString());

                      if (chatModuleEnabled) {
                        final userId =
                            context.read<AuthCubit>().getUserDetails().id ?? 0;

                        context.read<SocketSettingCubit>().init(userId: userId);
                      } else {
                        setState(() {
                          _bottomNavItems
                              .removeWhere((e) => e.title == chatKey);
                        });
                      }
                    }
                  },
                  builder: (context, state) {
                    final chatModuleEnabled = context
                        .read<StaffAllowedPermissionsAndModulesCubit>()
                        .isModuleEnabled(moduleId: chatModuleId.toString());

                    return Stack(
                      children: [
                        Align(
                          alignment: Alignment.topCenter,
                          child: IndexedStack(
                            index: _currentSelectedBottomNavIndex,
                            children: [
                              if (context.read<AuthCubit>().isTeacher()) ...[
                                const TeacherHomeContainer(),
                              ] else ...[
                                HomeContainer(key: HomeContainer.widgetKey),
                              ],
                              const AcademicsContainer(),
                              if (chatModuleEnabled)
                                MultiBlocProvider(
                                  providers: [
                                    BlocProvider(
                                      create: (_) =>
                                          ParentsUserChatHistoryCubit(),
                                    ),
                                    BlocProvider(
                                      create: (_) =>
                                          StudentsUserChatHistoryCubit(),
                                    ),
                                    BlocProvider(
                                      create: (_) =>
                                          StaffsUserChatHistoryCubit(),
                                    ),
                                  ],
                                  child: const ChatContainer(),
                                ),
                              const ProfileContainer(),
                            ],
                          ),
                        ),
                        if (state
                            is StaffAllowedPermissionsAndModulesFetchSuccess)
                          SafeArea(child: _buildBottomNavigationContainer()),
                        context.read<AppConfigurationCubit>().forceUpdate()
                            ? FutureBuilder<bool>(
                                future: Utils.forceUpdate(
                                  context
                                      .read<AppConfigurationCubit>()
                                      .getAppVersion(),
                                ),
                                builder: (context, snaphsot) {
                                  if (snaphsot.hasData) {
                                    return (snaphsot.data ?? false)
                                        ? const ForceUpdateDialogContainer()
                                        : const SizedBox();
                                  }

                                  return const SizedBox();
                                },
                              )
                            : const SizedBox(),
                      ],
                    );
                  },
                ),
              ),
      ),
    );
  }
}
