import 'package:dio/dio.dart';
import 'package:samy_mossad_assistant/core/constants.dart';
import 'package:samy_mossad_assistant/core/dio_helper.dart';
import 'package:samy_mossad_assistant/modules/students/data_source/models/student_model.dart';
import 'package:samy_mossad_assistant/modules/students/data_source/students_remote_data_source.dart';

class StudentsRemoteDataSourceImpl implements StudentsRemoteDataSource {
  @override
  Future<List<StudentModel>> getAllStudents() async {
    try {
      final Response response = await DioHelper.get(
        path: Endpoints.getAllStudents,
      );

      if (response.data['status'] == true &&
          response.data['statusCode'] == 200) {
        final List<dynamic> studentsData = response.data['data'];
        return studentsData.map((json) => StudentModel.fromJson(json)).toList();
      } else {
        throw Exception(response.data['message'] ?? 'فشل في جلب الطلاب');
      }
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        throw Exception(e.response?.data['message'] ?? 'حدث خطأ في الاتصال');
      }
      throw Exception('حدث خطأ في الاتصال: ${e.message}');
    } catch (e) {
      throw Exception('حدث خطأ: ${e.toString()}');
    }
  }
}
