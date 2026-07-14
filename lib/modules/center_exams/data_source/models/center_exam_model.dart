import 'package:samy_mossad_assistant/modules/center_exams/domain/entities/center_exam_entity.dart';

class CenterExamModel extends CenterExamEntity {
  const CenterExamModel({
    required super.id,
    required super.name,
    required super.classroomId,
    required super.classroomName,
    required super.centerId,
    required super.centerName,
    required super.totalMarks,
    required super.createdAt,
  });

  factory CenterExamModel.fromJson(Map<String, dynamic> json) {
    return CenterExamModel(
      id: json['id'],
      name: json['name'],
      classroomId: json['classroom_id'],
      classroomName: json['classroom']['name'],
      centerId: json['center_id'],
      centerName: json['center']['name'],
      totalMarks: json['total_marks'],
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'classroom_id': classroomId,
      'classroom_name': classroomName,
      'center_id': centerId,
      'center_name': centerName,
      'total_marks': totalMarks,
      'created_at': createdAt,
    };
  }
}
