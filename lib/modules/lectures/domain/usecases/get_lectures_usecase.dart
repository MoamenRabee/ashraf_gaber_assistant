import 'package:dartz/dartz.dart';
import 'package:samy_mossad_assistant/modules/lectures/domain/entities/lecture_entity.dart';
import 'package:samy_mossad_assistant/modules/lectures/domain/repository/lectures_repository.dart';

class GetLecturesUseCase {
  final LecturesRepository repository;

  GetLecturesUseCase(this.repository);

  Future<Either<String, List<LectureEntity>>> call() async {
    return await repository.getLectures();
  }
}
