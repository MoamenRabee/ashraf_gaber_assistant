import 'package:dartz/dartz.dart';
import 'package:samy_mossad_assistant/modules/lectures/domain/entities/local_attendance_entity.dart';
import 'package:samy_mossad_assistant/modules/lectures/domain/entities/student_absence_entity.dart';

abstract class AttendanceRepository {
  Future<Either<String, void>> syncAttendance(
    int lectureId,
    List<LocalAttendanceEntity> attendanceList,
  );

  Future<Either<String, void>> addMakeUpStudent({
    required int lectureId,
    required int studentCode,
    String? notes,
  });

  Future<Either<String, StudentAbsenceEntity>> checkStudentAbsence({
    required List<String> dates,
    required int classroomId,
    required int centerId,
    required int studentCode,
  });
}
