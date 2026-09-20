class Constants {
  static const String baseUrl = "https://ashraf-gaber.codak-e-school.com/api";
  // static const String baseUrl = "http://172.20.10.2/ashraf_gaber/public/api";
  static const String storage = "https://ashraf-gaber.codak-e-school.com/storage";
  // static const String storage = "http://172.20.10.2/ashraf_gaber/public/storage"; 
}

class Endpoints {
  static const String login = "/auth/login/assistant";
  static const String getAllStudents = "/assistants/getAllStudents";
  static const String getLectures = "/assistants/lectures";
  static const String getLectureStudents = "/assistants/getLectureStudents";
  static const String uploadStudentData = "/assistants/uploadStudentData";
  static const String endLecture = "/assistants/endLecture";
  static const String reopenLecture = "/assistants/reopenLecture";
  static const String createLecture = "/assistants/createLecture";
  static const String addMakeUpStudent = "/assistants/addMakeUpStudent";
  static const String getLocalExams = "/assistants/local-exams";
  static String getExamResults(int examId) => "/assistants/local-exams/$examId/results";
  static String getExamStudents(int classroomId, int centerId) =>
      "/assistants/students?classroom_id=$classroomId&center_id=$centerId";
  static const String addStudentResult = "/assistants/local-exams/student-result";
  static String getComments({String? status, int? page, int? perPage}) {
    String path = "/assistants/comments";
    List<String> params = [];
    if (status != null) params.add("status=$status");
    if (page != null) params.add("page=$page");
    if (perPage != null) params.add("per_page=$perPage");
    return params.isEmpty ? path : "$path?${params.join('&')}";
  }

  static String replyToComment(int commentId) => "/assistants/comments/$commentId/reply";
}

class CacheKeysName {
  static const String accessToken = "accessToken";
}
