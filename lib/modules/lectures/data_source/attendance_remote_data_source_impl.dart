import 'package:dio/dio.dart';
import 'package:samy_mossad_assistant/core/constants.dart';
import 'package:samy_mossad_assistant/core/dio_helper.dart';
import 'package:samy_mossad_assistant/modules/lectures/data_source/attendance_remote_data_source.dart';
import 'package:samy_mossad_assistant/modules/lectures/data_source/models/student_absence_model.dart';

class AttendanceRemoteDataSourceImpl implements AttendanceRemoteDataSource {
  AttendanceRemoteDataSourceImpl();

  @override
  Future<void> syncAttendance(
    int lectureId,
    List<Map<String, dynamic>> students,
  ) async {
    try {
      final response = await DioHelper.post(
        path: Endpoints.uploadStudentData,
        data: {'lecture_id': lectureId, 'students': students},
      );

      if (response.data['status'] != true) {
        throw Exception(response.data['message'] ?? 'فشل في المزامنة');
      }
    } catch (e) {
      throw Exception('فشل في المزامنة: ${e.toString()}');
    }
  }

  @override
  Future<void> addMakeUpStudent({
    required int lectureId,
    required int studentCode,
    String? notes,
  }) async {
    try {
      final response = await DioHelper.post(
        path: Endpoints.addMakeUpStudent,
        data: {
          'student_id': studentCode.toString(),
          'lecture_id': lectureId,
          'status': 'attended',
          'is_make_up': true,
          if (notes != null && notes.isNotEmpty) 'notes': notes,
        },
      );

      if (response.data['status'] != true) {
        throw Exception(response.data['message'] ?? 'فشل في تسجيل التعويض');
      }
    } on DioException catch (e) {
      throw Exception('حدث خطأ في الاتصال: ${e.message}');
    }
  }

  @override
  Future<StudentAbsenceModel> checkStudentAbsence({
    required List<String> dates,
    required int classroomId,
    required int centerId,
    required int studentCode,
  }) async {
    try {
      final response = await DioHelper.post(
        path: Endpoints.checkStudentAbsence,
        data: {
          'dates': dates,
          'classroom_id': classroomId,
          'center_id': centerId,
          'student_id': studentCode.toString(),
        },
      );

      final body = response.data;
      if (body is! Map || body['status'] != true || body['data'] is! Map) {
        throw Exception(
          (body is Map ? body['message'] : null) ?? 'فشل في فحص غياب الطالب',
        );
      }

      return StudentAbsenceModel.fromJson(
        Map<String, dynamic>.from(body['data'] as Map),
        message: body['message']?.toString(),
      );
    } on DioException catch (e) {
      throw Exception('حدث خطأ في الاتصال: ${e.message}');
    }
  }
}
