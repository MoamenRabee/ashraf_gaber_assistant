import 'package:samy_mossad_assistant/modules/center_exams/domain/entities/exam_result_entity.dart';

class ExamResultModel extends ExamResultEntity {
  const ExamResultModel({
    required super.id,
    required super.localExamId,
    required super.studentId,
    required super.studentName,
    required super.studentCode,
    required super.studentPhone,
    required super.parentPhone,
    required super.mark,
    super.notes,
  });

  factory ExamResultModel.fromJson(Map<String, dynamic> json) {
    return ExamResultModel(
      id: json['id'],
      localExamId: json['local_exam_id'],
      studentId: json['student_id'],
      studentName: json['student']['name'],
      studentCode: json['student']['student_id'],
      studentPhone: json['student']['phone'],
      parentPhone: json['student']['parent_phone'],
      mark: double.parse(json['mark'].toString()),
      notes: json['notes'],
    );
  }
}
