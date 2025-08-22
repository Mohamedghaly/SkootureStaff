import 'package:eschool_saas_staff/app/routes.dart';
import 'package:eschool_saas_staff/cubits/appConfigurationCubit.dart';
import 'package:eschool_saas_staff/cubits/authentication/authCubit.dart';
import 'package:eschool_saas_staff/ui/widgets/errorContainer.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1), // Fade duration
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(_fadeController);

    Future.delayed(const Duration(milliseconds: 300), () {
      _fadeController.forward();
      if (mounted) {
        context.read<AppConfigurationCubit>().fetchAppConfiguration();
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void navigateToNextScreen() async {
    if (context.read<AuthCubit>().state is Unauthenticated) {
      Get.offNamed(Routes.loginScreen);
    } else {
      Get.offNamed(Routes.homeScreen);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: BlocConsumer<AppConfigurationCubit, AppConfigurationState>(
        listener: (context, state) async {
          if (state is AppConfigurationFetchSuccess)  {
            await Future.delayed(const Duration(seconds: 2)); // Change as needed
            navigateToNextScreen();
          }
        },
        builder: (context, state) {
          final height = MediaQuery.of(context).size.height * 0.45;
          final width = MediaQuery.of(context).size.width * 0.8;
          print('Splash image size -> height: $height, width: $width');
          if (state is AppConfigurationFetchFailure) {
            return Center(
              child: ErrorContainer(
                errorMessage: state.errorMessage,
                onTapRetry: () {
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
    );
  }
}
