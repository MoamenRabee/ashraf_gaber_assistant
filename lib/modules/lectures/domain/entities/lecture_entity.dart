import 'package:equatable/equatable.dart';
import 'package:samy_mossad_assistant/modules/students/domain/entities/center_entity.dart';
import 'package:samy_mossad_assistant/modules/students/domain/entities/classroom_entity.dart';

enum LectureStatus {
  pending,
  ended;

  static LectureStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return LectureStatus.pending;
      case 'ended':
        return LectureStatus.ended;
      default:
        return LectureStatus.pending;
    }
  }
}

class LectureEntity extends Equatable {
  final int id;
  final String description;
  final ClassroomEntity classroom;
  final CenterEntity center;
  final String date;
  final String time;
  final LectureStatus status;
  final int? videoId;
  final int? viewLimit;

  const LectureEntity({
    required this.id,
    required this.description,
    required this.classroom,
    required this.center,
    required this.date,
    required this.time,
    required this.status,
    this.videoId,
    this.viewLimit,
  });

  @override
  List<Object?> get props => [
    id,
    description,
    classroom,
    center,
    date,
    time,
    status,
    videoId,
    viewLimit,
  ];
}
