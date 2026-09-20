import 'package:dartz/dartz.dart';
import 'package:samy_mossad_assistant/modules/lectures/domain/repository/lectures_repository.dart';

class CreateLectureUseCase {
  final LecturesRepository repository;

  CreateLectureUseCase(this.repository);

  Future<Either<String, void>> call({
    required String description,
    required int classroomId,
    required int centerId,
    required String date,
    required String time,
  }) {
    return repository.createLecture(
      description: description,
      classroomId: classroomId,
      centerId: centerId,
      date: date,
      time: time,
    );
  }
}
