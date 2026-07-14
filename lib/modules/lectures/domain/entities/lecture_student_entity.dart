import 'package:equatable/equatable.dart';

class LectureStudentEntity extends Equatable {
  final int id;
  final int studentId;
  final String name;
  final String phone;
  final String parentPhone;
  final int classroomId;
  final int centerId;
  final AttendanceEntity attendance;

  const LectureStudentEntity({
    required this.id,
    required this.studentId,
    required this.name,
    required this.phone,
    required this.parentPhone,
    required this.classroomId,
    required this.centerId,
    required this.attendance,
  });

  @override
  List<Object?> get props => [
    id,
    studentId,
    name,
    phone,
    parentPhone,
    classroomId,
    centerId,
    attendance,
  ];
}

class AttendanceEntity extends Equatable {
  final int lectureId;
  final int studentId;
  final String status; // "attended" or "not_attended"
  final String? attendedAt;

  const AttendanceEntity({
    required this.lectureId,
    required this.studentId,
    required this.status,
    this.attendedAt,
  });

  bool get isAttended => status == 'attended';

  @override
  List<Object?> get props => [lectureId, studentId, status, attendedAt];
}
