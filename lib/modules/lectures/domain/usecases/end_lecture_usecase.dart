import 'package:dartz/dartz.dart';
import 'package:samy_mossad_assistant/modules/lectures/domain/repository/lectures_repository.dart';

class EndLectureUseCase {
  final LecturesRepository repository;

  EndLectureUseCase(this.repository);

  Future<Either<String, Map<String, dynamic>>> call(int lectureId) async {
    return await repository.endLecture(lectureId);
  }
}
