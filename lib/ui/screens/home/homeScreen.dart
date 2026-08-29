import 'package:eschool_saas_staff/cubits/appConfigurationCubit.dart';
import 'package:eschool_saas_staff/cubits/authentication/authCubit.dart';
import 'package:eschool_saas_staff/cubits/chat/chatParentsUserChatHistoryCubit.dart';
import 'package:eschool_saas_staff/cubits/chat/chatStaffsUserChatHistoryCubit.dart';
import 'package:eschool_saas_staff/cubits/chat/chatStudentsUserChatHistoryCubit.dart';
import 'package:eschool_saas_staff/cubits/chat/socketSettingsCubit.dart';
import 'package:eschool_saas_staff/cubits/transport/tripsCubit.dart';
import 'package:eschool_saas_staff/cubits/userDetails/staffAllowedPermissionsAndModulesCubit.dart';
import 'package:eschool_saas_staff/data/models/bottomNavItem.dart';
import 'package:eschool_saas_staff/ui/screens/home/widgets/academicsContainer/academicsContainer.dart';
import 'package:eschool_saas_staff/ui/screens/home/widgets/appUnderMaintenanceContainer.dart';
import 'package:eschool_saas_staff/ui/screens/home/widgets/chatContainer/chatContainer.dart';
import 'package:eschool_saas_staff/ui/screens/home/widgets/forceUpdateDialogContainer.dart';
import 'package:eschool_saas_staff/ui/screens/home/widgets/homeContainer/homeContainer.dart';
import 'package:eschool_saas_staff/ui/screens/home/widgets/profileContainer.dart';
import 'package:eschool_saas_staff/ui/screens/home/widgets/teacherHomeContainer/teacherHomeContainer.dart';
import 'package:eschool_saas_staff/ui/screens/home/widgets/driverHomeContainer/driverHomeContainer.dart';
import 'package:eschool_saas_staff/ui/screens/home/widgets/myTripContainer/myTripContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/bottomNavItemContainer.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/notificationUtility.dart';
import 'package:eschool_saas_staff/utils/systemModulesAndPermissions.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  // HomeScreenDataCubit is provided globally — no local BlocProvider needed.
  static Widget getRouteInstance() => const HomeScreen();

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with WidgetsBindingObserver, RouteAware {
  int _currentSelectedBottomNavIndex = 0;
  var canPop = false;

  // Track which tabs have been visited for lazy loading
  final Set<int> _visitedTabs = {0}; // Home tab is always visited initially
  TripsCubit? _tripsCubit; // Keep reference to avoid recreating

  // Global key to access MyTripContainer
  final GlobalKey _myTripContainerKey = GlobalKey();

  // Global key to access DriverHomeContainer
  final GlobalKey _driverHomeContainerKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    Future.delayed(Duration.zero, () {
      if (mounted) {
        NotificationUtility.setUpNotificationService();
        final permCubit =
            context.read<StaffAllowedPermissionsAndModulesCubit>();
        permCubit.getPermissionAndAllowedModules();
        // Permissions may already be Success (loaded by splash prefetch).
        // BlocConsumer listener only fires on state *changes*, so init
        // the socket here if the state is already loaded.
        if (permCubit.state is StaffAllowedPermissionsAndModulesFetchSuccess) {
          _initSocketFromPermissions();
        }
      }
    });
  }

  void _initSocketFromPermissions() {
    final chatModuleEnabled = context
        .read<StaffAllowedPermissionsAndModulesCubit>()
        .isModuleEnabled(moduleId: chatModuleId.toString());
    if (chatModuleEnabled) {
      final userId = context.read<AuthCubit>().getUserDetails().id ?? 0;
      context.read<SocketSettingCubit>().init(userId: userId);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // This will be called when returning from other screens
    final modalRoute = ModalRoute.of(context);
    if (modalRoute != null && modalRoute.isCurrent) {
      final isDriver = context.read<AuthCubit>().isDriver();

      // Check if we're currently on Home tab (for driver) and refresh if needed
      if (_currentSelectedBottomNavIndex == 0 &&
          isDriver &&
          _visitedTabs.contains(0)) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _refreshDriverHomeTabIfNeeded();
        });
      }

      // Check if we're currently on My Trip tab and refresh if needed
      if (_currentSelectedBottomNavIndex == 1 && _visitedTabs.contains(1)) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _refreshMyTripTabIfNeeded();
        });
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tripsCubit?.close(); // Clean up the cubit
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // App lifecycle state changed - notifications will be fetched from API when needed
    // When app resumes from background, recheck notification permissions
    // This handles the case where user manually enables notifications in Settings
    if (state == AppLifecycleState.resumed) {
      NotificationUtility.recheckNotificationPermissions();

      // Profile may have been changed from the admin panel while the app was
      // in the background — re-sync the stored user details.
      context.read<AuthCubit>().refreshProfile();

      // Reconnect WebSocket when app returns from background
      final chatModuleEnabled = context
          .read<StaffAllowedPermissionsAndModulesCubit>()
          .isModuleEnabled(moduleId: chatModuleId.toString());

      if (chatModuleEnabled) {
        context.read<SocketSettingCubit>().reconnect();
      }
    }
  }

  List<BottomNavItem> _getBottomNavItems() {
    final authCubit = context.read<AuthCubit>();
    final chatModuleEnabled = context
        .read<StaffAllowedPermissionsAndModulesCubit>()
        .isModuleEnabled(moduleId: chatModuleId.toString());

    if (authCubit.isDriver()) {
      List<BottomNavItem> items = [
        BottomNavItem(
            iconPath: "home.svg",
            title: homeKey,
            selectedIconPath: "home_active.svg"),
        BottomNavItem(
            iconPath: "my_trip.svg",
            title: myTripKey,
            selectedIconPath: "my_trip_active.svg"),
      ];

      if (chatModuleEnabled) {
        items.add(BottomNavItem(
            iconPath: "chat.svg",
            title: chatKey,
            selectedIconPath: "chat_active.svg"));
      }

      items.add(BottomNavItem(
          iconPath: "profile.svg",
          title: profileKey,
          selectedIconPath: "profile_active.svg"));

      return items;
    } else {
      List<BottomNavItem> items = [
        BottomNavItem(
            iconPath: "home.svg",
            title: homeKey,
            selectedIconPath: "home_active.svg"),
        BottomNavItem(
            iconPath: "academics.svg",
            title: academicsKey,
            selectedIconPath: "academics_active.svg"),
      ];

      if (chatModuleEnabled) {
        items.add(BottomNavItem(
            iconPath: "chat.svg",
            title: chatKey,
            selectedIconPath: "chat_active.svg"));
      }

      items.add(BottomNavItem(
          iconPath: "profile.svg",
          title: profileKey,
          selectedIconPath: "profile_active.svg"));

      return items;
    }
  }

  void changeCurrentBottomNavIndex(int index) {
    setState(() {
      _currentSelectedBottomNavIndex = index;
      _visitedTabs.add(index); // Mark tab as visited

      // Refresh Home tab when user switches to it (for driver)
      if (index == 0 && context.read<AuthCubit>().isDriver()) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _refreshDriverHomeTabIfNeeded();
        });
      }

      // Refresh My Trip tab when user switches to it
      if (index == 1 && _visitedTabs.contains(1)) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _refreshMyTripTabIfNeeded();
        });
      }
    });

    // Profile tab (always the last item for every role) — re-sync the stored
    // user details so admin-panel changes show as soon as the tab is opened.
    if (index == _getBottomNavItems().length - 1) {
      context.read<AuthCubit>().refreshProfile();
    }
  }

  void _refreshMyTripTabIfNeeded() {
    // Refresh My Trip tab data when user switches to it or returns from other screens
    MyTripContainer.refreshData(_myTripContainerKey);
  }

  void _refreshDriverHomeTabIfNeeded() {
    // Refresh Driver Home tab data when user switches to it or returns from other screens
    DriverHomeContainer.refreshData(_driverHomeContainerKey);
  }

  Widget _buildMyTripContainer() {
    // For driver, My Trip is at index 1
    const myTripTabIndex = 1;

    // Only create and provide the cubit if the tab has been visited
    if (_visitedTabs.contains(myTripTabIndex)) {
      // Create cubit only once and reuse it
      _tripsCubit ??= TripsCubit();

      return BlocProvider.value(
        value: _tripsCubit!,
        child: MyTripContainer(key: _myTripContainerKey),
      );
    } else {
      // Return a placeholder that will be replaced when tab is visited
      return const SizedBox.shrink();
    }
  }

  List<Widget> _buildScreens(bool chatModuleEnabled) {
    final authCubit = context.read<AuthCubit>();

    if (authCubit.isDriver()) {
      return [
        DriverHomeContainer(
          key: _driverHomeContainerKey,
          onNavigateToMyTrips: () => changeCurrentBottomNavIndex(1),
        ),
        _buildMyTripContainer(),
        if (chatModuleEnabled)
          MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (_) => ParentsUserChatHistoryCubit(),
              ),
              BlocProvider(
                create: (_) => StudentsUserChatHistoryCubit(),
              ),
              BlocProvider(
                create: (_) => StaffsUserChatHistoryCubit(),
              ),
            ],
            child: const ChatContainer(),
          ),
        const ProfileContainer(),
      ];
    } else {
      return [
        if (authCubit.isTeacher()) ...[
          const TeacherHomeContainer(),
        ] else ...[
          HomeContainer(key: HomeContainer.widgetKey),
        ],
        const AcademicsContainer(),
        if (chatModuleEnabled)
          MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (_) => ParentsUserChatHistoryCubit(),
              ),
              BlocProvider(
                create: (_) => StudentsUserChatHistoryCubit(),
              ),
              BlocProvider(
                create: (_) => StaffsUserChatHistoryCubit(),
              ),
            ],
            child: const ChatContainer(),
          ),
        const ProfileContainer(),
      ];
    }
  }

  Widget _buildBottomNavigationContainer() {
    final bottomNavItems = _getBottomNavItems();

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
          children: List.generate(bottomNavItems.length, (index) => index)
              .map((index) => Expanded(
                    child: BottomNavItemContainer(
                        index: index,
                        bottomNavItem: bottomNavItems[index],
                        onTap: changeCurrentBottomNavIndex,
                        selectedBottomNavIndex: _currentSelectedBottomNavIndex),
                  ))
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
                      _initSocketFromPermissions();
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
                            children: _buildScreens(chatModuleEnabled),
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
