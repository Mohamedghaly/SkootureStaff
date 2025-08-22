import 'package:dio/dio.dart';
import 'package:eschool_saas_staff/data/models/teacherAnnouncement.dart';
import 'package:eschool_saas_staff/utils/api.dart';
import 'package:file_picker/file_picker.dart';

class TeacherAnnouncementRepository {
  Future<
      ({
        List<TeacherAnnouncement> announcements,
        int currentPage,
        int totalPage
      })> fetchAnnouncements({
    int? page,
    required int classSubjectId,
    required int classSectionId,
  }) async {
    try {
      Map<String, dynamic> queryParameters = {
        "page": page ?? 0,
        "class_subject_id": classSubjectId,
        "class_section_id": classSectionId
      };
      if (queryParameters['page'] == 0) {
        queryParameters.remove("page");
      }

      final result = await Api.get(
        url: Api.getAnnouncement,
        useAuthToken: true,
        queryParameters: queryParameters,
      );

      return (
        announcements: (result['data']['data'] as List)
            .map((e) => TeacherAnnouncement.fromJson(Map.from(e)))
            .toList(),
        totalPage: result['data']['last_page'] as int,
        currentPage: result['data']['current_page'] as int,
      );
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<void> createAnnouncement(
      {required String title,
      required String description,
      required List<PlatformFile> attachments,
      required List<int> classSectionId,
      required int classSubjectId,
      required String url}) async {
    try {
      List<MultipartFile> files = [];
      for (var file in attachments) {
        files.add(await MultipartFile.fromFile(file.path!));
      }
      Map<String, dynamic> body = {
        "class_section_id": classSectionId,
        "class_subject_id": classSubjectId,
        "title": title,
        "description": description,
        "file": files,
        "url": url
      };

      if (url.isEmpty) {
        body.remove('url');
      }

      if (files.isEmpty) {
        body.remove('file');
      }
      if (description.isEmpty) {
        body.remove('description');
      }

      await Api.post(
        body: body,
        url: Api.createAnnouncement,
        useAuthToken: true,
      );
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<void> updateAnnouncement(
      {required String title,
      required String description,
      required List<PlatformFile> attachments,
      required List<int> classSectionId,
      required int classSubjectId,
      required int announcementId,
      required String url}) async {
    try {
      List<MultipartFile> files = [];
      for (var file in attachments) {
        files.add(await MultipartFile.fromFile(file.path!));
      }
      Map<String, dynamic> body = {
        "announcement_id": announcementId,
        "class_section_id": classSectionId,
        "class_subject_id": classSubjectId,
        "title": title,
        "description": description,
        "file": files,
        "other_link": url
      };
      if (files.isEmpty) {
        body.remove('file');
      }
      if (description.isEmpty) {
        body.remove('description');
      }

      await Api.post(
        body: body,
        url: Api.updateAnnouncement,
        useAuthToken: true,
      );
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<void> deleteAnnouncement(int announcementId) async {
    try {
      await Api.post(
        body: {"announcement_id": announcementId},
        url: Api.deleteAnnouncement,
        useAuthToken: true,
      );
    } catch (e) {
      throw ApiException(e.toString());
    }
  }
}
