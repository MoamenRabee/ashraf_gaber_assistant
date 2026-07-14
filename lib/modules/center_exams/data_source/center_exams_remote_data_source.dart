import 'package:samy_mossad_assistant/modules/center_exams/domain/entities/center_exam_entity.dart';

abstract class CenterExamsRemoteDataSource {
  Future<List<CenterExamEntity>> getCenterExams();
}
