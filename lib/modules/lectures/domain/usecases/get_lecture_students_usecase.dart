import 'package:dartz/dartz.dart';
import 'package:samy_mossad_assistant/modules/lectures/domain/entities/lecture_student_entity.dart';
import 'package:samy_mossad_assistant/modules/lectures/domain/repository/lecture_students_repository.dart';

class GetLectureStudentsUseCase {
  final LectureStudentsRepository repository;

  GetLectureStudentsUseCase(this.repository);

  Future<Either<String, List<LectureStudentEntity>>> call(int lectureId) {
    return repository.getLectureStudents(lectureId);
  }
}
