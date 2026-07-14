import 'package:samy_mossad_assistant/modules/lectures/data_source/models/lecture_model.dart';

abstract class LecturesRemoteDataSource {
  Future<List<LectureModel>> getLectures();
  Future<Map<String, dynamic>> endLecture(int lectureId);
  Future<Map<String, dynamic>> reopenLecture(int lectureId);
}
