import 'package:samy_mossad_assistant/modules/students/data_source/models/student_model.dart';

abstract class StudentsLocalDataSource {
  Future<void> cacheStudents(List<StudentModel> students);
  Future<List<StudentModel>> getLocalStudents();
  Future<List<StudentModel>> searchStudents({
    String? searchQuery,
    int? classroomId,
    int? centerId,
  });
  Future<int> getStudentsCount();
  Future<List<Map<String, dynamic>>> getAllClassrooms();
  Future<List<Map<String, dynamic>>> getAllCenters();
}
