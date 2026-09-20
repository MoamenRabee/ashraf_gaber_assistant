import 'package:dartz/dartz.dart';
import 'package:samy_mossad_assistant/modules/lectures/domain/repository/attendance_repository.dart';

class AddMakeUpStudentUseCase {
  final AttendanceRepository repository;

  AddMakeUpStudentUseCase(this.repository);

  Future<Either<String, void>> call({
    required int lectureId,
    required int studentCode,
    String? notes,
  }) {
    return repository.addMakeUpStudent(
      lectureId: lectureId,
      studentCode: studentCode,
      notes: notes,
    );
  }
}
