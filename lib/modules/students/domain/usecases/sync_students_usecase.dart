import 'package:dartz/dartz.dart';
import 'package:samy_mossad_assistant/modules/students/domain/entities/student_entity.dart';
import 'package:samy_mossad_assistant/modules/students/domain/repository/students_repository.dart';

class SyncStudentsUseCase {
  final StudentsRepository repository;

  SyncStudentsUseCase(this.repository);

  Future<Either<String, List<StudentEntity>>> call() async {
    return await repository.syncStudents();
  }
}
