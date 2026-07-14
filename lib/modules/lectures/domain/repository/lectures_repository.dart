import 'package:dartz/dartz.dart';
import 'package:samy_mossad_assistant/modules/lectures/domain/entities/lecture_entity.dart';

abstract class LecturesRepository {
  Future<Either<String, List<LectureEntity>>> getLectures();
  Future<Either<String, Map<String, dynamic>>> endLecture(int lectureId);
  Future<Either<String, Map<String, dynamic>>> reopenLecture(int lectureId);
}
