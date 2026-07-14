import 'package:samy_mossad_assistant/modules/center_exams/domain/entities/exam_result_entity.dart';
import 'package:samy_mossad_assistant/modules/center_exams/domain/entities/exam_student_entity.dart';

abstract class ExamResultsRemoteDataSource {
  Future<List<ExamResultEntity>> getExamResults(int examId);
  Future<List<ExamStudentEntity>> getExamStudents(
    int classroomId,
    int centerId,
  );
  Future<void> addStudentResult({
    required int localExamId,
    required int studentId,
    required double mark,
    String? notes,
  });
}
