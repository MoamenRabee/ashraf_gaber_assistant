abstract class AttendanceRemoteDataSource {
  Future<void> syncAttendance(
    int lectureId,
    List<Map<String, dynamic>> students,
  );
}
