import 'package:dartz/dartz.dart';
import 'package:samy_mossad_assistant/modules/lectures/domain/entities/local_attendance_entity.dart';
import 'package:samy_mossad_assistant/modules/lectures/domain/repository/attendance_repository.dart';

class SyncAttendanceUseCase {
  final AttendanceRepository repository;

  SyncAttendanceUseCase(this.repository);

  Future<Either<String, void>> call(
    int lectureId,
    List<LocalAttendanceEntity> attendanceList,
  ) {
    return repository.syncAttendance(lectureId, attendanceList);
  }
}
