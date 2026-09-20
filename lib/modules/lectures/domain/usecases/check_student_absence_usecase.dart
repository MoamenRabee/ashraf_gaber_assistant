import 'package:dartz/dartz.dart';
import 'package:samy_mossad_assistant/modules/lectures/domain/entities/student_absence_entity.dart';
import 'package:samy_mossad_assistant/modules/lectures/domain/repository/attendance_repository.dart';

class CheckStudentAbsenceUseCase {
  final AttendanceRepository repository;

  CheckStudentAbsenceUseCase(this.repository);

  Future<Either<String, StudentAbsenceEntity>> call({
    required List<String> dates,
    required int classroomId,
    required int centerId,
    required int studentCode,
  }) {
    return repository.checkStudentAbsence(
      dates: dates,
      classroomId: classroomId,
      centerId: centerId,
      studentCode: studentCode,
    );
  }
}
