import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:eschool_saas_staff/app/routes.dart';
import 'package:eschool_saas_staff/ui/screens/home/widgets/chatContainer/chatScreen.dart';
import 'package:eschool_saas_staff/ui/screens/leaves/leavesScreen.dart';
import 'package:eschool_saas_staff/utils/api.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

class NotificationUtility {
  static String notificationType = "custom";
  static String leaveType = "Leave";
  static String messageType = "Message";
  static String attendanceType = "Attendance";
  static String payrollType = "Payroll";
  static String transportationType = "Transportation";

  //

  static Future<void> _handleMessageNotification(
      Map<String, dynamic> data) async {
    debugPrint(
        '[Broadcast][message] Processing message notification with data: $data');

    // Check if we have the required data for direct chat navigation
    final String? receiverIdStr = data['receiver_id'] ??
        data['receiverId'] ??
        data['sender_id'] ??
        data['senderId'];
    final String? teacherName = data['teacher_name'] ??
        data['teacherName'] ??
        data['sender_name'] ??
        data['senderName'];
    final String? teacherImage = data['teacher_image'] ??
        data['teacherImage'] ??
        data['sender_image'] ??
        data['senderImage'];
    final String? subjectName =
        data['subject_name'] ?? data['subjectName'] ?? data['subject'];

    if (receiverIdStr != null && teacherName != null) {
      // We have enough data to navigate directly to chat
      try {
        final int receiverId = int.parse(receiverIdStr);
        final String image = teacherImage ?? '';

        debugPrint(
            '[Broadcast][message] Navigating directly to chat with receiverId=$receiverId, teacherName=$teacherName');

        if (Get.currentRoute != Routes.chatScreen) {
          // Add a flag to indicate this chat was opened from notification
          final arguments = ChatScreen.buildArguments(
            receiverId: receiverId,
            receiverName: teacherName,
            receiverImage: image,
          );
          arguments['fromNotification'] =
              true; // Flag to indicate notification navigation

          Get.toNamed(
            Routes.chatScreen,
            arguments: arguments,
          );
        }
      } catch (e) {
        debugPrint(
            '[Broadcast][message][error] Failed to parse receiverId: $e');
        // Fallback to chat contacts
        _navigateToChatContacts();
      }
    } else {
      // Not enough data for direct navigation, fallback to chat contacts
      debugPrint(
          '[Broadcast][message] Insufficient data for direct chat navigation, falling back to chat contacts');
      debugPrint(
          '[Broadcast][message] Available data: receiverId=$receiverIdStr, teacherName=$teacherName, teacherImage=$teacherImage, subjectName=$subjectName');
      _navigateToChatContacts();
    }
  }

  // Helper method to navigate to chat contacts
  static void _navigateToChatContacts() {
    debugPrint('[Broadcast][message] Navigating to chat contacts');
    if (Get.currentRoute != Routes.chatContacts) {
      Get.toNamed(Routes.chatContacts);
    }
  }

  /// Handle attendance notification and navigate to teacher attendance screen
  static Future<void> _handleAttendanceNotification(
      Map<String, dynamic> data) async {
    debugPrint(
        '[Broadcast][attendance] Processing attendance notification with data: $data');

    try {
      // Check if we're not already on the attendance screen
      if (Get.currentRoute != Routes.teacherMyAttendanceScreen) {
        debugPrint(
            '[Broadcast][attendance] Navigating to teacher my attendance screen');

        // Add a small delay to ensure the app is ready for navigation
        await Future.delayed(const Duration(milliseconds: 100));

        // Navigate to teacher attendance screen
        await Get.toNamed(Routes.teacherMyAttendanceScreen);

        debugPrint(
            '[Broadcast][attendance] Successfully navigated to teacher attendance screen');
      } else {
        debugPrint(
            '[Broadcast][attendance] Already on teacher attendance screen, skipping navigation');
      }
    } catch (e) {
      debugPrint(
          '[Broadcast][attendance][error] Failed to navigate to attendance screen: $e');
    }
  }

  /// Handle payroll notification and navigate to my payroll screen
  static Future<void> _handlePayrollNotification(
      Map<String, dynamic> data) async {
    debugPrint(
        '[Broadcast][payroll] Processing payroll notification with data: $data');

    try {
      // Check if we're not already on the payroll screen
      if (Get.currentRoute != Routes.myPayrollScreen) {
        debugPrint('[Broadcast][payroll] Navigating to my payroll screen');

        // Add a small delay to ensure the app is ready for navigation
        await Future.delayed(const Duration(milliseconds: 100));

        // Navigate to my payroll screen
        await Get.toNamed(Routes.myPayrollScreen);

        debugPrint(
            '[Broadcast][payroll] Successfully navigated to my payroll screen');
      } else {
        debugPrint(
            '[Broadcast][payroll] Already on my payroll screen, skipping navigation');
      }
    } catch (e) {
      debugPrint(
          '[Broadcast][payroll][error] Failed to navigate to payroll screen: $e');
    }
  }

  /// Handle transportation notification and navigate to transport enroll home screen
  static Future<void> _handleTransportationNotification(
      Map<String, dynamic> data) async {
    debugPrint(
        '[Broadcast][transportation] Processing transportation notification with data: $data');

    try {
      // Extract userId from the notification data
      // Check multiple possible key formats for userId
      final String? userIdStr = data['user_id'] ??
          data['userId'] ??
          data['staff_id'] ??
          data['staffId'];

      if (userIdStr != null) {
        debugPrint(
            '[Broadcast][transportation] Extracted userId: $userIdStr from notification data');
      } else {
        debugPrint(
            '[Broadcast][transportation] No userId found in notification data, using logged-in user');
      }

      // Check if we're not already on the transport home screen
      if (Get.currentRoute != Routes.transportEnrollHomeScreen) {
        debugPrint(
            '[Broadcast][transportation] Navigating to transport enroll home screen');

        // Add a small delay to ensure the app is ready for navigation
        await Future.delayed(const Duration(milliseconds: 100));

        // Navigate to transport enroll home screen
        // Note: TransportHomeScreen fetches userId from AuthCubit internally
        // The userId from notification is logged for debugging purposes
        await Get.toNamed(Routes.transportEnrollHomeScreen);

        debugPrint(
            '[Broadcast][transportation] Successfully navigated to transport enroll home screen');
      } else {
        debugPrint(
            '[Broadcast][transportation] Already on transport enroll home screen, skipping navigation');
      }
    } catch (e) {
      debugPrint(
          '[Broadcast][transportation][error] Failed to navigate to transport screen: $e');
    }
  }

  static void _onTapNotificationScreenNavigateCallback({
    required Map<String, dynamic> notificationData,
  }) {
    print("This is the Notification Data ${notificationData}");
    final type = (notificationData['type'] ?? "").toString().toLowerCase();

    debugPrint('[Notification] Processing notification with type: $type');

    if (type.isNotEmpty) {
      if (type == notificationType) {
        Get.toNamed(Routes.notificationsScreen);
      } else if (type == leaveType.toLowerCase()) {
        Get.toNamed(Routes.leavesScreen,
            arguments: LeavesScreen.buildArguments(showMyLeaves: true));
        // Get.toNamed(Routes.leaveRequestScreen);
      } else if (type == messageType.toLowerCase()) {
        if (Get.currentRoute != Routes.chatContacts) {
          _handleMessageNotification(notificationData);
        }
      } else if (type == attendanceType.toLowerCase()) {
        // Handle attendance notification with dedicated async method
        debugPrint('[Notification] Matched attendance type, navigating...');
        _handleAttendanceNotification(notificationData);
      } else if (type == payrollType.toLowerCase()) {
        // Handle payroll notification with dedicated async method
        debugPrint('[Notification] Matched payroll type, navigating...');
        _handlePayrollNotification(notificationData);
      } else if (type == transportationType.toLowerCase()) {
        // Handle transportation notification with dedicated async method
        debugPrint('[Notification] Matched transportation type, navigating...');
        _handleTransportationNotification(notificationData);
      } else {
        debugPrint('[Notification] Unknown notification type: $type');
      }
    }
  }

  static final FlutterLocalNotificationsPlugin
      _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  //

  //Ask notification permission here
  static Future<NotificationSettings> _getNotificationPermission() async {
    return await FirebaseMessaging.instance.requestPermission(
      alert: false,
      announcement: false,
      badge: false,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
    );
  }

  static Future<void> setUpNotificationService() async {
    NotificationSettings notificationSettings =
        await FirebaseMessaging.instance.getNotificationSettings();

    //ask for permission
    if (notificationSettings.authorizationStatus ==
        AuthorizationStatus.notDetermined) {
      notificationSettings = await _getNotificationPermission();

      //if permission is provisionnal or authorised
      if (notificationSettings.authorizationStatus ==
              AuthorizationStatus.authorized ||
          notificationSettings.authorizationStatus ==
              AuthorizationStatus.provisional) {
        _initNotificationListener();
      }

      //if permission denied
    } else if (notificationSettings.authorizationStatus ==
        AuthorizationStatus.denied) {
      //If user denied then ask again
      notificationSettings = await _getNotificationPermission();
      if (notificationSettings.authorizationStatus ==
          AuthorizationStatus.denied) {
        return;
      }
    }
    _initNotificationListener();
  }

  static Future<void> recheckNotificationPermissions() async {
    try {
      // Check Firebase Messaging permission status
      NotificationSettings notificationSettings =
          await FirebaseMessaging.instance.getNotificationSettings();

      debugPrint(
          'Rechecking notification permissions: ${notificationSettings.authorizationStatus}');

      // If permission is now granted, initialize and register token
      if (notificationSettings.authorizationStatus ==
              AuthorizationStatus.authorized ||
          notificationSettings.authorizationStatus ==
              AuthorizationStatus.provisional) {
        // Initialize listeners if not already done
        _initNotificationListener();

        debugPrint('Notification services re-initialized successfully');
      }
    } catch (e) {
      debugPrint('Failed to recheck notification permissions: $e');
    }
  }

  static void _initNotificationListener() {
    if (kDebugMode) {
      debugPrint("Notification setup done");
    }
    FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: false, // Required to display a heads up notification
      badge: false,
      sound: false,
    );
    FirebaseMessaging.onMessage.listen(foregroundMessageListener);
    FirebaseMessaging.onBackgroundMessage(onBackgroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(onMessageOpenedAppListener);

    FirebaseMessaging.instance.getInitialMessage().then((value) {
      if (kDebugMode) {
        debugPrint("Initial notification");
        debugPrint(value?.toMap().toString());
      }
      _onTapNotificationScreenNavigateCallback(
        notificationData: value?.data ?? {},
      );
    });

    if (!kIsWeb) {
      _initLocalNotification();
    }
  }

  static void foregroundMessageListener(RemoteMessage remoteMessage) async {
    final additionalData = remoteMessage.data;

    createLocalNotification(
        dismissable: true,
        imageUrl: (additionalData['image'] ?? "").toString(),
        title: remoteMessage.notification?.title ?? "You have new notification",
        body: remoteMessage.notification?.body ?? "",
        payload: jsonEncode(additionalData));
  }

  static void onMessageOpenedAppListener(RemoteMessage remoteMessage) {
    _onTapNotificationScreenNavigateCallback(
        notificationData: remoteMessage.data);
  }

  static void _initLocalNotification() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();

    InitializationSettings initializationSettings =
        const InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    _requestPermissionsForIos();
    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) async {
        _onTapNotificationScreenNavigateCallback(
            notificationData:
                Map<String, dynamic>.from(jsonDecode(details.payload ?? "")));
      },
    );
  }

  static Future<void> _requestPermissionsForIos() async {
    if (Platform.isIOS) {
      _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions();
    }
  }

  static Future<void> createLocalNotification(
      {required String title,
      required bool dismissable, //User can clear it
      required String body,
      required String imageUrl,
      required String payload}) async {
    late AndroidNotificationDetails androidPlatformChannelSpecifics;
    if (imageUrl.isNotEmpty) {
      final downloadedImagePath = await _downloadAndSaveFile(imageUrl);
      if (downloadedImagePath.isEmpty) {
        //If somwhow failed to download image
        androidPlatformChannelSpecifics = AndroidNotificationDetails(
            'com.global.talent.competition', //channel id
            'Local notification',

            //channel name
            importance: Importance.max,
            priority: Priority.high,
            ongoing: !dismissable,
            ticker: 'ticker');
      } else {
        var bigPictureStyleInformation = BigPictureStyleInformation(
            FilePathAndroidBitmap(downloadedImagePath),
            hideExpandedLargeIcon: true,
            contentTitle: title,
            htmlFormatContentTitle: true,
            summaryText: title,
            htmlFormatSummaryText: true);

        androidPlatformChannelSpecifics = AndroidNotificationDetails(
            'com.global.talent.competition', //channel id
            'Local notification', //channel name

            importance: Importance.max,
            priority: Priority.high,
            largeIcon: FilePathAndroidBitmap(downloadedImagePath),
            styleInformation: bigPictureStyleInformation,
            ongoing: !dismissable,
            ticker: 'ticker');
      }
    } else {
      androidPlatformChannelSpecifics = AndroidNotificationDetails(
          'com.global.talent.competition', //channel id
          'Local notification', //channel name

          importance: Importance.max,
          priority: Priority.high,
          ongoing: !dismissable,
          ticker: 'ticker');
    }
    const DarwinNotificationDetails iosNotificationDetails =
        DarwinNotificationDetails();

    var platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics, iOS: iosNotificationDetails);
    await _flutterLocalNotificationsPlugin
        .show(0, title, body, platformChannelSpecifics, payload: payload);
  }

  // Download notification methods
  static Future<void> showDownloadNotification({
    required int notificationId,
    required String fileName,
    required int progress,
  }) async {
    try {
      final AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'download_channel',
        'Download notifications',
        channelDescription: 'Shows download progress and completion',
        importance: Importance.max,
        priority: Priority.high,
        showProgress: true,
        maxProgress: 100,
        progress: progress, // Add the initial progress value
        ongoing: true,
        autoCancel: false,
      );

      final NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);

      await _flutterLocalNotificationsPlugin.show(
        notificationId,
        '${Utils.getTranslatedLabel(downloadingFileKey)} (${progress}%)',
        fileName,
        platformChannelSpecifics,
        payload: 'download_start',
      );
    } catch (e) {
      // Silently handle notification errors
    }
  }

  static Future<void> updateDownloadNotification({
    required int notificationId,
    required String fileName,
    required int progress,
  }) async {
    try {
      final AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'download_channel',
        'Download notifications',
        channelDescription: 'Shows download progress and completion',
        importance: Importance.max,
        priority: Priority.high,
        showProgress: true,
        maxProgress: 100,
        progress: progress, // This was missing!
        ongoing: true,
        autoCancel: false,
      );

      final NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);

      await _flutterLocalNotificationsPlugin.show(
        notificationId,
        '${Utils.getTranslatedLabel(downloadingFileKey)} ($progress%)',
        fileName,
        platformChannelSpecifics,
        payload: 'download_progress',
      );
    } catch (e) {
      // Silently handle notification errors
    }
  }

  static Future<void> showDownloadCompleteNotification({
    required int notificationId,
    required String fileName,
  }) async {
    try {
      // Use a different notification ID for completion to avoid conflicts
      final completionNotificationId = notificationId + 1000;

      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'download_complete_channel',
        'Download complete notifications',
        channelDescription: 'Shows download completion status',
        importance: Importance.max,
        priority: Priority.high,
        ongoing: false,
        autoCancel: true,
        showProgress: false, // No progress bar for completion
      );

      const NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);

      // First, cancel the progress notification
      await _flutterLocalNotificationsPlugin.cancel(notificationId);

      // Small delay to ensure the progress notification is cancelled
      await Future.delayed(const Duration(milliseconds: 100));

      await _flutterLocalNotificationsPlugin.show(
        completionNotificationId,
        Utils.getTranslatedLabel(downloadCompleteKey),
        '$fileName ${Utils.getTranslatedLabel(fileDownloadedSuccessfullyKey)}',
        platformChannelSpecifics,
        payload: 'download_complete',
      );

      // Auto-dismiss the notification after 5 seconds
      Future.delayed(const Duration(seconds: 5), () {
        try {
          _flutterLocalNotificationsPlugin.cancel(completionNotificationId);
        } catch (e) {
          // Silently handle dismissal errors
        }
      });
    } catch (e) {
      // Silently handle notification errors
    }
  }

  static Future<void> showDownloadErrorNotification({
    required int notificationId,
    required String fileName,
    required String error,
  }) async {
    try {
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'download_channel',
        'Download notifications',
        channelDescription: 'Shows download progress and completion',
        importance: Importance.max,
        priority: Priority.high,
        ongoing: false,
        autoCancel: true,
      );

      const NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);

      await _flutterLocalNotificationsPlugin.show(
        notificationId,
        Utils.getTranslatedLabel(downloadFailedKey),
        '${Utils.getTranslatedLabel(failedToDownloadKey)} $fileName',
        platformChannelSpecifics,
        payload: 'download_error',
      );

      // Auto-dismiss the notification after 5 seconds
      Future.delayed(const Duration(seconds: 5), () {
        try {
          _flutterLocalNotificationsPlugin.cancel(notificationId);
        } catch (e) {
          // Silently handle dismissal errors
        }
      });
    } catch (e) {
      // Silently handle notification errors
    }
  }

  static Future<String> _downloadAndSaveFile(String url) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final String filePath = '${directory.path}/temp.jpg';

    try {
      await Api.download(
          url: url,
          cancelToken: CancelToken(),
          savePath: filePath,
          updateDownloadedPercentage: (value) {});

      return filePath;
    } catch (e) {
      return "";
    }
  }
}

@pragma('vm:entry-point')
Future<void> onBackgroundMessage(
  RemoteMessage remoteMessage,
) async {
  if (kDebugMode) {
    debugPrint(remoteMessage.toMap().toString());
  }
  // Background message received - notification will be shown by Firebase
  // Data will be fetched from API when user opens the notification screen
}
