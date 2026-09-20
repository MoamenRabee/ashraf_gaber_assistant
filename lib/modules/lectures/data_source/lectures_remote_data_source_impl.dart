import 'package:dio/dio.dart';
import 'package:samy_mossad_assistant/core/constants.dart';
import 'package:samy_mossad_assistant/core/dio_helper.dart';
import 'package:samy_mossad_assistant/modules/lectures/data_source/lectures_remote_data_source.dart';
import 'package:samy_mossad_assistant/modules/lectures/data_source/models/lecture_model.dart';

class LecturesRemoteDataSourceImpl implements LecturesRemoteDataSource {
  @override
  Future<List<LectureModel>> getLectures() async {
    try {
      final Response response = await DioHelper.get(path: Endpoints.getLectures);

      if (response.data['status'] == true && response.data['statusCode'] == 200) {
        final List<dynamic> lecturesData = response.data['data'];
        return lecturesData.map((json) => LectureModel.fromJson(json)).toList();
      } else {
        throw Exception(response.data['message'] ?? 'فشل في جلب المحاضرات');
      }
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        throw Exception(e.response?.data['message'] ?? 'حدث خطأ في الاتصال');
      }
      throw Exception('حدث خطأ في الاتصال: ${e.message}');
    } catch (e) {
      throw Exception('حدث خطأ: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, dynamic>> endLecture(int lectureId) async {
    try {
      final Response response = await DioHelper.post(path: Endpoints.endLecture, data: {'lecture_id': lectureId});

      if (response.data['status'] == true && response.data['statusCode'] == 200) {
        return response.data;
      } else {
        throw Exception(response.data['message'] ?? 'فشل في إنهاء المحاضرة');
      }
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        throw Exception(e.response?.data['message'] ?? 'حدث خطأ في الاتصال');
      }
      throw Exception('حدث خطأ في الاتصال: ${e.message}');
    } catch (e) {
      throw Exception('حدث خطأ: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, dynamic>> reopenLecture(int lectureId) async {
    try {
      final Response response = await DioHelper.post(path: Endpoints.reopenLecture, data: {'lecture_id': lectureId});

      if (response.data['status'] == true && response.data['statusCode'] == 200) {
        return response.data;
      } else {
        throw Exception(response.data['message'] ?? 'فشل في إعادة فتح المحاضرة');
      }
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        throw Exception(e.response?.data['message'] ?? 'حدث خطأ في الاتصال');
      }
      throw Exception('حدث خطأ في الاتصال: ${e.message}');
    } catch (e) {
      throw Exception('حدث خطأ: ${e.toString()}');
    }
  }

  @override
  Future<void> createLecture({
    required String description,
    required int classroomId,
    required int centerId,
    required String date,
    required String time,
  }) async {
    try {
      final Response response = await DioHelper.post(
        path: Endpoints.createLecture,
        data: {
          'description': description,
          'classroom_id': classroomId,
          'center_id': centerId,
          'date': date,
          'time': time,
        },
      );

      final data = response.data;
      if (data is! Map || data['status'] != true) {
        throw Exception((data is Map ? data['message'] : null) ?? 'فشل في إضافة المحاضرة');
      }
    } on DioException catch (e) {
      throw Exception('حدث خطأ في الاتصال: ${e.message}');
    }
  }
}
