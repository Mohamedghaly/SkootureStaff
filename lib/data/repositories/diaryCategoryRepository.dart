import 'package:eschool_saas_staff/data/models/diaryCategory.dart';
import 'package:eschool_saas_staff/utils/api.dart';

class DiaryCategoryRepository {
  Future<List<DiaryCategory>> getDiaryCategories({
    required String type, // "positive" or "negative"
  }) async {
    try {
      final result = await Api.get(
        url: Api.getDiaryCategories,
        useAuthToken: true,
        queryParameters: {
          "type": type,
        },
      );

      return ((result['data'] ?? []) as List)
          .map((category) => DiaryCategory.fromJson(Map.from(category ?? {})))
          .toList();
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<List<DiaryCategory>> getAllDiaryCategories() async {
    try {
      final result = await Api.get(
        url: Api.getDiaryCategories,
        useAuthToken: true,
        // No type parameter to get all categories
      );

      return ((result['data'] ?? []) as List)
          .map((category) => DiaryCategory.fromJson(Map.from(category ?? {})))
          .toList();
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<DiaryCategory> createDiaryCategory({
    required String name,
    required String type, // "positive" or "negative"
  }) async {
    try {
      final result = await Api.post(
        url: Api.createDiaryCategory,
        useAuthToken: true,
        body: {
          "name": name,
          "type": type,
        },
      );

      return DiaryCategory.fromJson(Map.from(result['data'] ?? {}));
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<DiaryCategory> updateDiaryCategory({
    required int diaryCategoryId,
    required String name,
    required String type, // "positive" or "negative"
  }) async {
    try {
      final result = await Api.post(
        url: Api.updateDiaryCategory,
        useAuthToken: true,
        body: {
          "diary_category_id": diaryCategoryId,
          "name": name,
          "type": type,
        },
      );

      return DiaryCategory.fromJson(Map.from(result['data'] ?? {}));
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<void> deleteDiaryCategory({
    required int diaryCategoryId,
  }) async {
    try {
      await Api.post(
        url: Api.deleteDiaryCategory,
        useAuthToken: true,
        body: {
          "diary_category_id": diaryCategoryId,
        },
      );
    } catch (e) {
      throw ApiException(e.toString());
    }
  }
}
