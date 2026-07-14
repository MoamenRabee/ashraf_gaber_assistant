import 'package:samy_mossad_assistant/modules/lectures/domain/entities/lecture_student_entity.dart';

abstract class LectureStudentsRemoteDataSource {
  Future<List<LectureStudentEntity>> getLectureStudents(int lectureId);
}
