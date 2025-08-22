import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:eschool_saas_staff/data/models/announcement.dart';
import 'package:eschool_saas_staff/data/models/notificationDetails.dart';
import 'package:eschool_saas_staff/data/repositories/authRepository.dart';
import 'package:eschool_saas_staff/utils/api.dart';
import 'package:eschool_saas_staff/utils/hiveBoxKeys.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AnnouncementRepository {
  Future<
      ({
        List<NotificationDetails> notifications,
        int currentPage,
        int totalPage
      })> getNotifications({int? page}) async {
    try {
      final result = await Api.get(url: Api.getNotifications, queryParameters: {
        "page": page ?? 1,
      });
      return (
        notifications: ((result['data']['data'] ?? []) as List)
            .map((notification) =>
                NotificationDetails.fromJson(Map.from(notification ?? {})))
            .toList(),
        currentPage: (result['data']['current_page'] as int),
        totalPage: (result['data']['last_page'] as int),
      );
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<({List<Announcement> announcements, int currentPage, int totalPage})>
      getAnnouncements({int? page, required List<int> classSectionIds}) async {
    try {
      final result = await Api.get(url: Api.getAnnouncements, queryParameters: {
        "page": page ?? 1,
        "class_section_id":
            classSectionIds.join(',') // Pass as comma-separated values
      });
      return (
        announcements: ((result['data']['data'] ?? []) as List)
            .map((announcement) =>
                Announcement.fromJson(Map.from(announcement ?? {})))
            .toList(),
        currentPage: (result['data']['current_page'] as int),
        totalPage: (result['data']['last_page'] as int),
      );
    } catch (e) {
 
      throw ApiException(e.toString());
    }
  }

  Future<void> deleteNotification({required int notificationId}) async {
    try {
      await Api.post(
          url: Api.deleteNotification,
          body: {"notification_id": notificationId});
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<void> deleteAnnouncement({required int announcementId}) async {
    try {
      await Api.post(
          url: Api.deleteGeneralAnnouncement,
          body: {"announcement_id": announcementId});
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<void> sendNotification(
      {required String title,
      required String message,
      required String sendTo,
      List<String>? roles,
      List<int>? userIds,
      String? filePath}) async {
    try {
      await Api.post(url: Api.sendNotification, body: {
        "title": title,
        "message": message,
        "type": sendTo,
        "user_id": userIds,
        "roles": roles,
        "file": (filePath ?? "").isEmpty
            ? null
            : (await MultipartFile.fromFile(filePath!))
      });
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<void> sendGeneralAnnouncement(
      {required String title,
      String? description,
      required List<int> classSectionIds,
      List<String>? filePaths}) async {
    try {
      List<MultipartFile>? files;

      if ((filePaths ?? []).isNotEmpty) {
        files = [];
        for (var filePath in filePaths!) {
          files.add(await MultipartFile.fromFile(filePath));
        }
      }
      await Api.post(url: Api.sendGeneralAnnouncement, body: {
        "title": title,
        "description": description,
        "class_section_id": classSectionIds,
        "file": files
      });
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<void> editGeneralAnnouncement(
      {required String title,
      String? description,
      required List<int> classSectionIds,
      required int announcementId,
      List<String>? filePaths}) async {
    try {
      List<MultipartFile>? files;

      if ((filePaths ?? []).isNotEmpty) {
        files = [];
        for (var filePath in filePaths!) {
          files.add(await MultipartFile.fromFile(filePath));
        }
      }
      await Api.post(url: Api.editGeneralAnnouncement, body: {
        "title": title,
        "description": description,
        "announcement_id": announcementId,
        "class_section_id": classSectionIds,
        "file": files
      });
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  static Future<void> addNotification(
      {required NotificationDetails notificationDetails}) async {
    try {
      await Hive.openBox(notificationsBoxKey);
      await Hive.box(notificationsBoxKey).put(
          notificationDetails.createdAt.toString(),
          notificationDetails.toJson());
  
    } catch (e) {
    
    }
  }

  static Future<void> addNotificationTemporarily(
      {required Map<String, dynamic> data}) async {
    try {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      await sharedPreferences.reload();
      List<String> notifications =
          sharedPreferences.getStringList(temporarilyStoredNotificationsKey) ??
              List<String>.from([]);

      notifications.add(jsonEncode(data));

      await sharedPreferences.setStringList(
          temporarilyStoredNotificationsKey, notifications);
    } catch (_) {}
  }

  static Future<List<Map<String, dynamic>>>
      getTemporarilyStoredNotifications() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.reload();
    List<String> notifications =
        sharedPreferences.getStringList(temporarilyStoredNotificationsKey) ??
            List<String>.from([]);

    return notifications
        .map((notificationData) =>
            Map<String, dynamic>.from(jsonDecode(notificationData) ?? {}))
        .toList();
  }

  static Future<void> clearTemporarilyNotification() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setStringList(temporarilyStoredNotificationsKey, []);
  }

  Future<List<NotificationDetails>> getLocalNotifications() async {
    try {
      Box notificationBox = Hive.box(notificationsBoxKey);
      List<NotificationDetails> notifications = [];

      for (var notificationKey in notificationBox.keys.toList()) {
        notifications.add(NotificationDetails.fromJson(
          Map.from(notificationBox.get(notificationKey) ?? {}),
        ));
      }

      final currentUserId = AuthRepository.getUserDetails().id;

      notifications = notifications
          .where((element) => element.id == currentUserId)
          .toList();

      notifications.sort(
          (first, second) => second.createdAt!.compareTo(first.createdAt!));

      return notifications;
    } catch (e) {
      throw ApiException(defaultErrorMessageKey);
    }
  }
}
