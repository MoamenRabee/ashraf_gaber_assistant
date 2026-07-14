import 'package:dartz/dartz.dart';
import 'package:samy_mossad_assistant/modules/center_exams/domain/repository/exam_results_repository.dart';

class AddStudentResultUseCase {
  final ExamResultsRepository repository;

  AddStudentResultUseCase({required this.repository});

  Future<Either<String, void>> call({
    required int localExamId,
    required int studentId,
    required double mark,
    String? notes,
  }) async {
    return await repository.addStudentResult(
      localExamId: localExamId,
      studentId: studentId,
      mark: mark,
      notes: notes,
    );
  }
}
