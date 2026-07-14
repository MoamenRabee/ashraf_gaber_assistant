import 'package:dartz/dartz.dart';
import 'package:samy_mossad_assistant/modules/lectures/data_source/lecture_students_remote_data_source.dart';
import 'package:samy_mossad_assistant/modules/lectures/domain/entities/lecture_student_entity.dart';
import 'package:samy_mossad_assistant/modules/lectures/domain/repository/lecture_students_repository.dart';

class LectureStudentsRepositoryImpl implements LectureStudentsRepository {
  final LectureStudentsRemoteDataSource remoteDataSource;

  LectureStudentsRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<String, List<LectureStudentEntity>>> getLectureStudents(
    int lectureId,
  ) async {
    try {
      final students = await remoteDataSource.getLectureStudents(lectureId);
      return Right(students);
    } catch (e) {
      return Left(e.toString());
    }
  }
}
