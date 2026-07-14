import 'package:samy_mossad_assistant/modules/center_exams/domain/entities/exam_student_entity.dart';

class ExamStudentModel extends ExamStudentEntity {
  ExamStudentModel({
    required super.id,
    required super.name,
    required super.code,
    super.phone,
    super.parentPhone,
  });

  factory ExamStudentModel.fromJson(Map<String, dynamic> json) {
    return ExamStudentModel(
      id: json['id'],
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      phone: json['phone'],
      parentPhone: json['parent_phone'],
    );
  }
}
