import 'package:dartz/dartz.dart';
import 'package:samy_mossad_assistant/modules/lectures/domain/entities/local_attendance_entity.dart';

abstract class AttendanceRepository {
  Future<Either<String, void>> syncAttendance(
    int lectureId,
    List<LocalAttendanceEntity> attendanceList,
  );
}
