import 'package:samy_mossad_assistant/modules/lectures/domain/entities/lecture_student_entity.dart';

class LectureStudentModel extends LectureStudentEntity {
  const LectureStudentModel({
    required super.id,
    required super.studentId,
    required super.name,
    required super.phone,
    required super.parentPhone,
    required super.classroomId,
    required super.centerId,
    required super.attendance,
  });

  factory LectureStudentModel.fromJson(Map<String, dynamic> json) {
    return LectureStudentModel(
      id: json['id'],
      studentId: json['student_id'],
      name: json['name'],
      phone: json['phone'],
      parentPhone: json['parent_phone'],
      classroomId: json['classroom_id'],
      centerId: json['center_id'],
      attendance: AttendanceModel.fromJson(json['pivot']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_id': studentId,
      'name': name,
      'phone': phone,
      'parent_phone': parentPhone,
      'classroom_id': classroomId,
      'center_id': centerId,
      'pivot': (attendance as AttendanceModel).toJson(),
    };
  }
}

class AttendanceModel extends AttendanceEntity {
  const AttendanceModel({
    required super.lectureId,
    required super.studentId,
    required super.status,
    super.attendedAt,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      lectureId: json['lecture_id'],
      studentId: json['student_id'],
      status: json['status'],
      attendedAt: json['attended_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lecture_id': lectureId,
      'student_id': studentId,
      'status': status,
      'attended_at': attendedAt,
    };
  }
}
