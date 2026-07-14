import 'package:dartz/dartz.dart';
import 'package:samy_mossad_assistant/modules/students/domain/repository/students_repository.dart';

class GetStudentsCountUseCase {
  final StudentsRepository repository;

  GetStudentsCountUseCase(this.repository);

  Future<Either<String, int>> call() async {
    return await repository.getStudentsCount();
  }
}
