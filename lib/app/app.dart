import 'dart:io';

import 'package:eschool_saas_staff/app/appTranslation.dart';
import 'package:eschool_saas_staff/app/routes.dart';
import 'package:eschool_saas_staff/cubits/appConfigurationCubit.dart';
import 'package:eschool_saas_staff/cubits/appLocalizationCubit.dart';
import 'package:eschool_saas_staff/cubits/authentication/authCubit.dart';
import 'package:eschool_saas_staff/cubits/chat/socketSettingsCubit.dart';
import 'package:eschool_saas_staff/cubits/schoolDetailsCubit.dart';
import 'package:eschool_saas_staff/cubits/teacherAcademics/teacherMyTimetableCubit.dart';
import 'package:eschool_saas_staff/cubits/userDetails/staffAllowedPermissionsAndModulesCubit.dart';
import 'package:eschool_saas_staff/data/repositories/settingsRepository.dart';
import 'package:eschool_saas_staff/firebase_options.dart';
import 'package:eschool_saas_staff/ui/styles/colors.dart';
import 'package:eschool_saas_staff/utils/hiveBoxKeys.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/route_manager.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:device_preview/device_preview.dart';

//to avoid handshake error on some devices
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

Future<void> initializeApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides();
  //Register the licence of font
  //If using google-fonts
  LicenseRegistry.addLicense(() async* {
    final license = await rootBundle.loadString('google_fonts/OFL.txt');
    yield LicenseEntryWithLineBreaks(['google_fonts'], license);
  });

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.dark));

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await AppTranslation.loadJsons();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await Hive.initFlutter();
  await Hive.openBox(authBoxKey);
  await Hive.openBox(settingsBoxKey);

  await Hive.openBox(notificationsBoxKey);

  runApp(
    DevicePreview(
      enabled: false,
      builder: (context) => const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider<SchooldetailsCubit>(
            create: (_) => SchooldetailsCubit(),
          ),
          BlocProvider<AppLocalizationCubit>(
            create: (_) => AppLocalizationCubit(SettingsRepository()),
          ),
          BlocProvider<AppConfigurationCubit>(
            create: (_) => AppConfigurationCubit(),
          ),
          BlocProvider<AuthCubit>(
            create: (_) => AuthCubit(),
          ),
          BlocProvider<StaffAllowedPermissionsAndModulesCubit>(
            create: (_) => StaffAllowedPermissionsAndModulesCubit(),
          ),
          BlocProvider<TeacherMyTimetableCubit>(
            create: (_) => TeacherMyTimetableCubit(),
          ),
          BlocProvider<SocketSettingCubit>(create: (_) => SocketSettingCubit()),
        ],
        child: Builder(builder: (context) {
          return GetMaterialApp(
            debugShowCheckedModeBanner: false,
            translationsKeys: AppTranslation.translationsKeys,
            theme: Theme.of(context).copyWith(
                extensions: <ThemeExtension<dynamic>>[customColorsExtension],
                textTheme:
                    GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
                scaffoldBackgroundColor: pageBackgroundColor,
                colorScheme: Theme.of(context).colorScheme.copyWith(
                    primary: primaryColor,
                    secondary: secondaryColor,
                    surface: backgroundColor,
                    error: errorColor,
                    tertiary: tertiaryColor)),
            getPages: Routes.getPages,
            initialRoute: Routes.splashScreen,
            locale: context.read<AppLocalizationCubit>().state.language,
            fallbackLocale: const Locale("en"),
          );
        }));
  }
}
