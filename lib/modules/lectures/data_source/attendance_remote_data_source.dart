import 'package:samy_mossad_assistant/modules/lectures/data_source/models/student_absence_model.dart';

abstract class AttendanceRemoteDataSource {
  Future<void> syncAttendance(
    int lectureId,
    List<Map<String, dynamic>> students,
  );

  Future<void> addMakeUpStudent({
    required int lectureId,
    required int studentCode,
    String? notes,
  });

  Future<StudentAbsenceModel> checkStudentAbsence({
    required List<String> dates,
    required int classroomId,
    required int centerId,
    required int studentCode,
  });
}
