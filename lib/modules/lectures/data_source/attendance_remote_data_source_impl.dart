import 'package:samy_mossad_assistant/core/constants.dart';
import 'package:samy_mossad_assistant/core/dio_helper.dart';
import 'package:samy_mossad_assistant/modules/lectures/data_source/attendance_remote_data_source.dart';

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
}
