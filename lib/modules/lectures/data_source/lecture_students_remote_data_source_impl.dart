import 'package:samy_mossad_assistant/core/constants.dart';
import 'package:samy_mossad_assistant/core/dio_helper.dart';
import 'package:samy_mossad_assistant/modules/lectures/data_source/lecture_students_remote_data_source.dart';
import 'package:samy_mossad_assistant/modules/lectures/data_source/models/lecture_student_model.dart';
import 'package:samy_mossad_assistant/modules/lectures/domain/entities/lecture_student_entity.dart';

class LectureStudentsRemoteDataSourceImpl
    implements LectureStudentsRemoteDataSource {
  LectureStudentsRemoteDataSourceImpl();

  @override
  Future<List<LectureStudentEntity>> getLectureStudents(int lectureId) async {
    try {
      final response = await DioHelper.get(
        path: Endpoints.getLectureStudents,
        queryParameters: {'id': lectureId},
      );

      if (response.data['status'] == true) {
        // البحث عن المحاضرة المطلوبة من array المحاضرات
        final List<dynamic> lectures = response.data['data'];
        final lecture = lectures.firstWhere(
          (l) => l['id'] == lectureId,
          orElse: () => throw Exception('المحاضرة غير موجودة'),
        );

        final List<dynamic> students = lecture['students'] ?? [];
        return students
            .map((json) => LectureStudentModel.fromJson(json))
            .toList();
      } else {
        throw Exception(response.data['message'] ?? 'فشل في تحميل الطلاب');
      }
    } catch (e) {
      throw Exception('فشل في تحميل الطلاب: ${e.toString()}');
    }
  }
}
