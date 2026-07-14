import 'package:dartz/dartz.dart';
import 'package:samy_mossad_assistant/modules/students/domain/repository/students_repository.dart';

class GetFiltersUseCase {
  final StudentsRepository repository;

  GetFiltersUseCase(this.repository);

  Future<Either<String, Map<String, List<Map<String, dynamic>>>>> call() async {
    try {
      final classroomsResult = await repository.getAllClassrooms();
      final centersResult = await repository.getAllCenters();

      if (classroomsResult.isLeft() || centersResult.isLeft()) {
        return const Left('فشل في جلب البيانات');
      }

      final classrooms = classroomsResult.getOrElse(() => []);
      final centers = centersResult.getOrElse(() => []);

      return Right({'classrooms': classrooms, 'centers': centers});
    } catch (e) {
      return Left(e.toString());
    }
  }
}
