import 'package:samy_mossad_assistant/modules/students/data_source/models/student_model.dart';

abstract class StudentsRemoteDataSource {
  Future<List<StudentModel>> getAllStudents();
}
