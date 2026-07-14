import 'package:samy_mossad_assistant/modules/students/domain/entities/classroom_entity.dart';

class ClassroomModel extends ClassroomEntity {
  const ClassroomModel({required super.id, required super.name});

  factory ClassroomModel.fromJson(Map<String, dynamic> json) {
    return ClassroomModel(id: json['id'] ?? 0, name: json['name'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}
