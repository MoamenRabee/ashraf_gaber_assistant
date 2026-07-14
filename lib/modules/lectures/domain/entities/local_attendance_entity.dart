import 'package:equatable/equatable.dart';

class LocalAttendanceEntity extends Equatable {
  final int? id;
  final int lectureId;
  final String lectureDescription;
  final int studentId;
  final String studentName;
  final int studentCode;
  final String attendedAt;
  final bool isSynced;

  const LocalAttendanceEntity({
    this.id,
    required this.lectureId,
    required this.lectureDescription,
    required this.studentId,
    required this.studentName,
    required this.studentCode,
    required this.attendedAt,
    this.isSynced = false,
  });

  @override
  List<Object?> get props => [
    id,
    lectureId,
    lectureDescription,
    studentId,
    studentName,
    studentCode,
    attendedAt,
    isSynced,
  ];
}
