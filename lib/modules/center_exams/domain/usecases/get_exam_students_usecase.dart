import 'package:dartz/dartz.dart';
import 'package:samy_mossad_assistant/modules/center_exams/domain/entities/exam_student_entity.dart';
import 'package:samy_mossad_assistant/modules/center_exams/domain/repository/exam_results_repository.dart';

class GetExamStudentsUseCase {
  final ExamResultsRepository repository;

  GetExamStudentsUseCase({required this.repository});

  Future<Either<String, List<ExamStudentEntity>>> call(
    int classroomId,
    int centerId,
  ) async {
    return await repository.getExamStudents(classroomId, centerId);
  }
}
