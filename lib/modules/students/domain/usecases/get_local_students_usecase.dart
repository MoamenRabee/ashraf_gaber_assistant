import 'package:dartz/dartz.dart';
import 'package:samy_mossad_assistant/modules/students/domain/entities/student_entity.dart';
import 'package:samy_mossad_assistant/modules/students/domain/repository/students_repository.dart';

class GetLocalStudentsUseCase {
  final StudentsRepository repository;

  GetLocalStudentsUseCase(this.repository);

  Future<Either<String, List<StudentEntity>>> call({
    String? searchQuery,
    int? classroomId,
    int? centerId,
  }) async {
    if (searchQuery != null || classroomId != null || centerId != null) {
      return await repository.searchStudents(
        searchQuery: searchQuery,
        classroomId: classroomId,
        centerId: centerId,
      );
    }
    return await repository.getLocalStudents();
  }
}
