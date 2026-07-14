import 'package:samy_mossad_assistant/core/constants.dart';
import 'package:samy_mossad_assistant/core/dio_helper.dart';
import 'package:samy_mossad_assistant/modules/center_exams/data_source/center_exams_remote_data_source.dart';
import 'package:samy_mossad_assistant/modules/center_exams/data_source/models/center_exam_model.dart';
import 'package:samy_mossad_assistant/modules/center_exams/domain/entities/center_exam_entity.dart';

class CenterExamsRemoteDataSourceImpl implements CenterExamsRemoteDataSource {
  @override
  Future<List<CenterExamEntity>> getCenterExams() async {
    try {
      final response = await DioHelper.get(path: Endpoints.getLocalExams);

      if (response.data['status'] == true) {
        final List<dynamic> exams = response.data['data'];
        return exams.map((json) => CenterExamModel.fromJson(json)).toList();
      } else {
        throw Exception(response.data['message'] ?? 'فشل في تحميل الامتحانات');
      }
    } catch (e) {
      throw Exception('فشل في تحميل الامتحانات: ${e.toString()}');
    }
  }
}
