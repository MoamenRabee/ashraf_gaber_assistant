import 'package:dartz/dartz.dart';
import 'package:samy_mossad_assistant/modules/center_exams/data_source/exam_results_remote_data_source.dart';
import 'package:samy_mossad_assistant/modules/center_exams/domain/entities/exam_result_entity.dart';
import 'package:samy_mossad_assistant/modules/center_exams/domain/entities/exam_student_entity.dart';
import 'package:samy_mossad_assistant/modules/center_exams/domain/repository/exam_results_repository.dart';

class ExamResultsRepositoryImpl implements ExamResultsRepository {
  final ExamResultsRemoteDataSource remoteDataSource;

  ExamResultsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<String, List<ExamResultEntity>>> getExamResults(
    int examId,
  ) async {
    try {
      final results = await remoteDataSource.getExamResults(examId);
      return Right(results);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, List<ExamStudentEntity>>> getExamStudents(
    int classroomId,
    int centerId,
  ) async {
    try {
      final students = await remoteDataSource.getExamStudents(
        classroomId,
        centerId,
      );
      return Right(students);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> addStudentResult({
    required int localExamId,
    required int studentId,
    required double mark,
    String? notes,
  }) async {
    try {
      await remoteDataSource.addStudentResult(
        localExamId: localExamId,
        studentId: studentId,
        mark: mark,
        notes: notes,
      );
      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }
}
