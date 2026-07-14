import 'package:samy_mossad_assistant/core/database_helper.dart';
import 'package:samy_mossad_assistant/modules/students/data_source/models/student_model.dart';
import 'package:samy_mossad_assistant/modules/students/data_source/students_local_data_source.dart';

class StudentsLocalDataSourceImpl implements StudentsLocalDataSource {
  final DatabaseHelper databaseHelper;

  StudentsLocalDataSourceImpl({required this.databaseHelper});

  @override
  Future<void> cacheStudents(List<StudentModel> students) async {
    await databaseHelper.insertStudents(students);
  }

  @override
  Future<List<StudentModel>> getLocalStudents() async {
    return await databaseHelper.getAllStudents();
  }

  @override
  Future<List<StudentModel>> searchStudents({
    String? searchQuery,
    int? classroomId,
    int? centerId,
  }) async {
    return await databaseHelper.searchStudents(
      searchQuery: searchQuery,
      classroomId: classroomId,
      centerId: centerId,
    );
  }

  @override
  Future<int> getStudentsCount() async {
    return await databaseHelper.getStudentsCount();
  }

  @override
  Future<List<Map<String, dynamic>>> getAllClassrooms() async {
    return await databaseHelper.getAllClassrooms();
  }

  @override
  Future<List<Map<String, dynamic>>> getAllCenters() async {
    return await databaseHelper.getAllCenters();
  }
}
