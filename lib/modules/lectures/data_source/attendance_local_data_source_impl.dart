import 'package:samy_mossad_assistant/core/database_helper.dart';
import 'package:samy_mossad_assistant/modules/lectures/data_source/attendance_local_data_source.dart';
import 'package:samy_mossad_assistant/modules/lectures/data_source/models/local_attendance_model.dart';
import 'package:samy_mossad_assistant/modules/lectures/domain/entities/local_attendance_entity.dart';
import 'package:samy_mossad_assistant/modules/students/domain/entities/student_entity.dart';

class AttendanceLocalDataSourceImpl implements AttendanceLocalDataSource {
  final DatabaseHelper databaseHelper;

  AttendanceLocalDataSourceImpl(this.databaseHelper);

  @override
  Future<int> addAttendance(LocalAttendanceEntity attendance) async {
    final model = LocalAttendanceModel(
      id: attendance.id,
      lectureId: attendance.lectureId,
      lectureDescription: attendance.lectureDescription,
      studentId: attendance.studentId,
      studentName: attendance.studentName,
      studentCode: attendance.studentCode,
      attendedAt: attendance.attendedAt,
      isSynced: attendance.isSynced,
    );
    return await databaseHelper.insertAttendance(model.toDatabase());
  }

  @override
  Future<List<LocalAttendanceEntity>> getAttendanceByLecture(
    int lectureId,
  ) async {
    final maps = await databaseHelper.getAttendanceByLecture(lectureId);
    return maps.map((map) => LocalAttendanceModel.fromDatabase(map)).toList();
  }

  @override
  Future<int> deleteAttendance(int id) async {
    return await databaseHelper.deleteAttendance(id);
  }

  @override
  Future<List<LocalAttendanceEntity>> getUnsyncedAttendance(
    int lectureId,
  ) async {
    final maps = await databaseHelper.getUnsyncedAttendance(lectureId);
    return maps.map((map) => LocalAttendanceModel.fromDatabase(map)).toList();
  }

  @override
  Future<int> markAttendanceAsSynced(int id) async {
    return await databaseHelper.markAttendanceAsSynced(id);
  }

  @override
  Future<StudentEntity?> getStudentByCode(int studentCode) async {
    return await databaseHelper.getStudentByCode(studentCode);
  }
}
