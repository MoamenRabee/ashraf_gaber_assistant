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
}
