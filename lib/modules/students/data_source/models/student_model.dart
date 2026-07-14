import 'package:samy_mossad_assistant/modules/students/data_source/models/center_model.dart';
import 'package:samy_mossad_assistant/modules/students/data_source/models/classroom_model.dart';
import 'package:samy_mossad_assistant/modules/students/domain/entities/student_entity.dart';

class StudentModel extends StudentEntity {
  const StudentModel({
    required super.id,
    required super.studentId,
    required super.name,
    required super.phone,
    required super.parentPhone,
    required super.classroom,
    required super.center,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      id: json['id'] ?? 0,
      studentId: json['student_id'] ?? 0,
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      parentPhone: json['parent_phone'] ?? '',
      classroom: ClassroomModel.fromJson(json['classroom'] ?? {}),
      center: CenterModel.fromJson(json['center'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_id': studentId,
      'name': name,
      'phone': phone,
      'parent_phone': parentPhone,
      'classroom_id': classroom.id,
      'classroom_name': classroom.name,
      'center_id': center.id,
      'center_name': center.name,
      'center_address': center.address,
    };
  }

  factory StudentModel.fromDatabase(Map<String, dynamic> map) {
    return StudentModel(
      id: map['id'] ?? 0,
      studentId: map['student_id'] ?? 0,
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      parentPhone: map['parent_phone'] ?? '',
      classroom: ClassroomModel(
        id: map['classroom_id'] ?? 0,
        name: map['classroom_name'] ?? '',
      ),
      center: CenterModel(
        id: map['center_id'] ?? 0,
        name: map['center_name'] ?? '',
        address: map['center_address'] ?? '',
      ),
    );
  }
}
