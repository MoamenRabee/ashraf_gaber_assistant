import 'package:dartz/dartz.dart';
import 'package:samy_mossad_assistant/modules/center_exams/domain/entities/exam_result_entity.dart';
import 'package:samy_mossad_assistant/modules/center_exams/domain/repository/exam_results_repository.dart';

class GetExamResultsUseCase {
  final ExamResultsRepository repository;

  GetExamResultsUseCase(this.repository);

  Future<Either<String, List<ExamResultEntity>>> call(int examId) {
    return repository.getExamResults(examId);
  }
}
