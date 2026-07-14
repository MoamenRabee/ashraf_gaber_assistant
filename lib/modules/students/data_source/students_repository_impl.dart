import 'package:dartz/dartz.dart';
import 'package:samy_mossad_assistant/modules/students/data_source/students_local_data_source.dart';
import 'package:samy_mossad_assistant/modules/students/data_source/students_remote_data_source.dart';
import 'package:samy_mossad_assistant/modules/students/domain/entities/student_entity.dart';
import 'package:samy_mossad_assistant/modules/students/domain/repository/students_repository.dart';

class StudentsRepositoryImpl implements StudentsRepository {
  final StudentsRemoteDataSource remoteDataSource;
  final StudentsLocalDataSource localDataSource;

  StudentsRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<String, List<StudentEntity>>> syncStudents() async {
    try {
      // جلب الطلاب من الـ API
      final students = await remoteDataSource.getAllStudents();

      // حفظهم في الـ SQLite
      await localDataSource.cacheStudents(students);

      return Right(students);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, List<StudentEntity>>> getLocalStudents() async {
    try {
      final students = await localDataSource.getLocalStudents();
      return Right(students);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, List<StudentEntity>>> searchStudents({
    String? searchQuery,
    int? classroomId,
    int? centerId,
  }) async {
    try {
      final students = await localDataSource.searchStudents(
        searchQuery: searchQuery,
        classroomId: classroomId,
        centerId: centerId,
      );
      return Right(students);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, int>> getStudentsCount() async {
    try {
      final count = await localDataSource.getStudentsCount();
      return Right(count);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, List<Map<String, dynamic>>>> getAllClassrooms() async {
    try {
      final classrooms = await localDataSource.getAllClassrooms();
      return Right(classrooms);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, List<Map<String, dynamic>>>> getAllCenters() async {
    try {
      final centers = await localDataSource.getAllCenters();
      return Right(centers);
    } catch (e) {
      return Left(e.toString());
    }
  }
}
