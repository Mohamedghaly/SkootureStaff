import 'package:dio/dio.dart';
import 'package:eschool_saas_staff/data/models/announcement.dart';
import 'package:eschool_saas_staff/data/models/notificationDetails.dart';
import 'package:eschool_saas_staff/utils/api.dart';

class AnnouncementRepository {
  Future<
      ({
        List<NotificationDetails> notifications,
        int offset,
        int limit,
        bool hasMore
      })> getNotifications({int? offset, int? limit}) async {
    try {
      final requestOffset = offset ?? 0;
      final requestLimit = limit ?? 10;

      final result = await Api.get(url: Api.getNotifications, queryParameters: {
        "offset": requestOffset,
        "limit": requestLimit,
      });

      // Parse notifications directly from data array
      final List<NotificationDetails> notifications =
          ((result['data'] ?? []) as List)
              .map((notification) =>
                  NotificationDetails.fromJson(Map.from(notification ?? {})))
              .toList();

      // Determine if there are more items
      // If we received fewer items than requested, we've reached the end
      final bool hasMore = notifications.length >= requestLimit;

      return (
        notifications: notifications,
        offset: requestOffset,
        limit: requestLimit,
        hasMore: hasMore,
      );
    } catch (e, st) {
      print("this is the error $e");
      print("this is the stack trace $st");
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
}
