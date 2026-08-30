import 'package:eschool_saas_staff/app/routes.dart';
import 'package:eschool_saas_staff/cubits/appConfigurationCubit.dart';
import 'package:eschool_saas_staff/cubits/appLocalizationCubit.dart';
import 'package:eschool_saas_staff/cubits/authentication/authCubit.dart';
import 'package:eschool_saas_staff/cubits/homeScreenDataCubit.dart';
import 'package:eschool_saas_staff/cubits/task/homeTasksCubit.dart';
import 'package:eschool_saas_staff/cubits/teacherAcademics/teacherMyTimetableCubit.dart';
import 'package:eschool_saas_staff/cubits/userDetails/staffAllowedPermissionsAndModulesCubit.dart';
import 'package:eschool_saas_staff/ui/widgets/errorContainer.dart';
import 'package:eschool_saas_staff/utils/systemModulesAndPermissions.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/route_manager.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();

  static Widget getRouteInstance() => const SplashScreen();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  bool _navigationStarted = false;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(_fadeController);

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _fadeController.forward();
        context.read<AppLocalizationCubit>().syncRemoteLocalization();
        context.read<AppConfigurationCubit>().fetchAppConfiguration();
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _prefetchAndNavigate() async {
    if (_navigationStarted) return;
    _navigationStarted = true;

    if (!mounted) return;

    final authCubit = context.read<AuthCubit>();
    if (authCubit.state is Unauthenticated) {
      Get.offNamed(Routes.loginScreen);
      return;
    }

    final permCubit = context.read<StaffAllowedPermissionsAndModulesCubit>();
    await _ensurePermissionsLoaded(permCubit);

    if (!mounted) return;

    _fireHomePreloads(permCubit, authCubit);

    Get.offNamed(Routes.homeScreen);
  }

  Future<void> _ensurePermissionsLoaded(
    StaffAllowedPermissionsAndModulesCubit permCubit,
  ) async {
    if (permCubit.state is StaffAllowedPermissionsAndModulesFetchSuccess) {
      return;
    }

    permCubit.getPermissionAndAllowedModules();

    await permCubit.stream.firstWhere(
      (s) =>
          s is StaffAllowedPermissionsAndModulesFetchSuccess ||
          s is StaffAllowedPermissionsAndModulesFetchFailure,
    );
  }

  void _fireHomePreloads(
    StaffAllowedPermissionsAndModulesCubit permCubit,
    AuthCubit authCubit,
  ) {
    final isTeacher = authCubit.isTeacher();

    authCubit.refreshProfile();

    context.read<HomeScreenDataCubit>().getHomeScreenData(
          isTeacher: isTeacher,
          holidayModuleEnabled: permCubit.isModuleEnabled(
              moduleId: holidayManagementModuleId.toString()),
          staffLeaveModuleEnabled: permCubit.isModuleEnabled(
              moduleId: staffLeaveManagementModuleId.toString()),
          listTeacherTimetablePermission: permCubit.isPermissionGiven(
              permission: viewTeachersPermissionKey),
        );

    context.read<HomeTasksCubit>().getTasks(type: 'my_tasks');

    if (isTeacher &&
        permCubit.isModuleEnabled(
            moduleId: timetableManagementModuleId.toString())) {
      context
          .read<TeacherMyTimetableCubit>()
          .getTeacherMyTimetable(isRefresh: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
        systemNavigationBarContrastEnforced: false,
        systemStatusBarContrastEnforced: false,
      ),
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.primary,
        body: BlocConsumer<AppConfigurationCubit, AppConfigurationState>(
          listener: (context, state) {
            if (state is AppConfigurationFetchSuccess) {
              _prefetchAndNavigate();
            }
          },
          builder: (context, state) {
            final height = MediaQuery.of(context).size.height * 0.45;
            final width = MediaQuery.of(context).size.width * 0.8;
            if (state is AppConfigurationFetchFailure) {
              return Center(
                child: ErrorContainer(
                  errorMessage: state.errorMessage,
                  onTapRetry: () {
                    _navigationStarted = false;
                    context.read<AppLocalizationCubit>().syncRemoteLocalization();
                    context.read<AppConfigurationCubit>().fetchAppConfiguration();
                  },
                  retryButtonTextColor: Theme.of(context).colorScheme.onSurface,
                ),
              );
            }
            return Center(
              child: SizedBox(
                height: height,
                width: width,
                child: AnimatedBuilder(
                  animation: _fadeAnimation,
                  builder: (context, child) => Opacity(
                    opacity: _fadeAnimation.value,
                    child: child,
                  ),
                  child: Image.asset(Utils.getImagePath("staff.png")),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
