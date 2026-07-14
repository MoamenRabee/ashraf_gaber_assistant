import 'package:dartz/dartz.dart';
import 'package:samy_mossad_assistant/modules/lectures/domain/entities/lecture_student_entity.dart';

abstract class LectureStudentsRepository {
  Future<Either<String, List<LectureStudentEntity>>> getLectureStudents(
    int lectureId,
  );
}
