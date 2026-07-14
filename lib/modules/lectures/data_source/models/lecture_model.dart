import 'package:samy_mossad_assistant/modules/lectures/domain/entities/lecture_entity.dart';
import 'package:samy_mossad_assistant/modules/students/data_source/models/center_model.dart';
import 'package:samy_mossad_assistant/modules/students/data_source/models/classroom_model.dart';

class LectureModel extends LectureEntity {
  const LectureModel({
    required super.id,
    required super.description,
    required super.classroom,
    required super.center,
    required super.date,
    required super.time,
    required super.status,
    super.videoId,
    super.viewLimit,
  });

  factory LectureModel.fromJson(Map<String, dynamic> json) {
    return LectureModel(
      id: json['id'] ?? 0,
      description: json['description'] ?? '',
      classroom: ClassroomModel.fromJson(json['classroom'] ?? {}),
      center: CenterModel.fromJson(json['center'] ?? {}),
      date: json['date'] ?? '',
      time: json['time'] ?? '',
      status: LectureStatus.fromString(json['status'] ?? 'pending'),
      videoId: json['video_id'],
      viewLimit: json['view_limit'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'classroom_id': classroom.id,
      'classroom_name': classroom.name,
      'center_id': center.id,
      'center_name': center.name,
      'date': date,
      'time': time,
      'status': status.name,
      'video_id': videoId,
      'view_limit': viewLimit,
    };
  }
}
