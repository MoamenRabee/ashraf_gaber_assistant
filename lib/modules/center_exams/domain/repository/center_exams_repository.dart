import 'package:dartz/dartz.dart';
import 'package:samy_mossad_assistant/modules/center_exams/domain/entities/center_exam_entity.dart';

abstract class CenterExamsRepository {
  Future<Either<String, List<CenterExamEntity>>> getCenterExams();
}
