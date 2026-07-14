import 'package:samy_mossad_assistant/core/constants.dart';
import 'package:samy_mossad_assistant/core/dio_helper.dart';
import 'package:samy_mossad_assistant/modules/center_exams/data_source/exam_results_remote_data_source.dart';
import 'package:samy_mossad_assistant/modules/center_exams/data_source/models/exam_result_model.dart';
import 'package:samy_mossad_assistant/modules/center_exams/data_source/models/exam_student_model.dart';
import 'package:samy_mossad_assistant/modules/center_exams/domain/entities/exam_result_entity.dart';
import 'package:samy_mossad_assistant/modules/center_exams/domain/entities/exam_student_entity.dart';

class ExamResultsRemoteDataSourceImpl implements ExamResultsRemoteDataSource {
  @override
  Future<List<ExamResultEntity>> getExamResults(int examId) async {
    try {
      final response = await DioHelper.get(
        path: Endpoints.getExamResults(examId),
      );

      if (response.data['status'] == true) {
        final List<dynamic> results = response.data['data'];
        return results.map((json) => ExamResultModel.fromJson(json)).toList();
      } else {
        throw Exception(response.data['message'] ?? 'فشل في تحميل النتائج');
      }
    } catch (e) {
      throw Exception('فشل في تحميل النتائج: ${e.toString()}');
    }
  }

  @override
  Future<List<ExamStudentEntity>> getExamStudents(
    int classroomId,
    int centerId,
  ) async {
    try {
      final response = await DioHelper.get(
        path: Endpoints.getExamStudents(classroomId, centerId),
      );

      if (response.data['status'] == true) {
        final List<dynamic> students = response.data['data'];
        return students.map((json) => ExamStudentModel.fromJson(json)).toList();
      } else {
        throw Exception(response.data['message'] ?? 'فشل في تحميل الطلاب');
      }
    } catch (e) {
      throw Exception('فشل في تحميل الطلاب: ${e.toString()}');
    }
  }

  @override
  Future<void> addStudentResult({
    required int localExamId,
    required int studentId,
    required double mark,
    String? notes,
  }) async {
    try {
      final response = await DioHelper.post(
        path: Endpoints.addStudentResult,
        data: {
          'local_exam_id': localExamId,
          'student_id': studentId,
          'mark': mark,
          if (notes != null && notes.isNotEmpty) 'notes': notes,
        },
      );

      if (response.data['status'] != true) {
        throw Exception(response.data['message'] ?? 'فشل في إضافة الدرجة');
      }
    } catch (e) {
      throw Exception('فشل في إضافة الدرجة: ${e.toString()}');
    }
  }
}
