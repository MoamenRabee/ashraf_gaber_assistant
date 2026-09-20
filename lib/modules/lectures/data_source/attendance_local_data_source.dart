import 'package:samy_mossad_assistant/modules/lectures/domain/entities/local_attendance_entity.dart';
import 'package:samy_mossad_assistant/modules/students/domain/entities/student_entity.dart';

abstract class AttendanceLocalDataSource {
  Future<int> addAttendance(LocalAttendanceEntity attendance);
  Future<List<LocalAttendanceEntity>> getAttendanceByLecture(int lectureId);
  Future<int> deleteAttendance(int id);
  Future<List<LocalAttendanceEntity>> getUnsyncedAttendance(int lectureId);
  Future<int> markAttendanceAsSynced(int id);
  Future<StudentEntity?> getStudentByCode(int studentCode, {int? centerId});
}
