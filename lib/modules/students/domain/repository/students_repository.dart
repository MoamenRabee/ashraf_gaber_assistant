import 'package:dartz/dartz.dart';
import 'package:samy_mossad_assistant/modules/students/domain/entities/student_entity.dart';

abstract class StudentsRepository {
  Future<Either<String, List<StudentEntity>>> syncStudents();
  Future<Either<String, List<StudentEntity>>> getLocalStudents();
  Future<Either<String, List<StudentEntity>>> searchStudents({
    String? searchQuery,
    int? classroomId,
    int? centerId,
  });
  Future<Either<String, int>> getStudentsCount();
  Future<Either<String, List<Map<String, dynamic>>>> getAllClassrooms();
  Future<Either<String, List<Map<String, dynamic>>>> getAllCenters();
}
