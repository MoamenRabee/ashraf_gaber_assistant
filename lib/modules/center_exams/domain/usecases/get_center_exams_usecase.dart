import 'package:dartz/dartz.dart';
import 'package:samy_mossad_assistant/modules/center_exams/domain/entities/center_exam_entity.dart';
import 'package:samy_mossad_assistant/modules/center_exams/domain/repository/center_exams_repository.dart';

class GetCenterExamsUseCase {
  final CenterExamsRepository repository;

  GetCenterExamsUseCase(this.repository);

  Future<Either<String, List<CenterExamEntity>>> call() {
    return repository.getCenterExams();
  }
}
