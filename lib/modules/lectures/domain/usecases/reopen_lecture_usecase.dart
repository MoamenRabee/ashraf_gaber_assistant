import 'package:dartz/dartz.dart';
import 'package:samy_mossad_assistant/modules/lectures/domain/repository/lectures_repository.dart';

class ReopenLectureUseCase {
  final LecturesRepository repository;

  ReopenLectureUseCase(this.repository);

  Future<Either<String, Map<String, dynamic>>> call(int lectureId) async {
    return await repository.reopenLecture(lectureId);
  }
}
