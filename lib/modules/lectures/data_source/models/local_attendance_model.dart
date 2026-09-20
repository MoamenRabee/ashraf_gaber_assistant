import 'package:samy_mossad_assistant/modules/lectures/domain/entities/local_attendance_entity.dart';

class LocalAttendanceModel extends LocalAttendanceEntity {
  const LocalAttendanceModel({
    super.id,
    required super.lectureId,
    required super.lectureDescription,
    required super.studentId,
    required super.studentName,
    required super.studentCode,
    required super.attendedAt,
    super.isSynced,
    super.isMakeUp,
  });

  factory LocalAttendanceModel.fromDatabase(Map<String, dynamic> map) {
    return LocalAttendanceModel(
      id: map['id'] as int?,
      lectureId: map['lecture_id'] as int,
      lectureDescription: map['lecture_description'] as String,
      studentId: map['student_id'] as int,
      studentName: map['student_name'] as String,
      studentCode: map['student_code'] as int,
      attendedAt: map['attended_at'] as String,
      isSynced: (map['is_synced'] as int) == 1,
      isMakeUp: (map['is_make_up'] as int? ?? 0) == 1,
    );
  }

  Map<String, dynamic> toDatabase() {
    return {
      if (id != null) 'id': id,
      'lecture_id': lectureId,
      'lecture_description': lectureDescription,
      'student_id': studentId,
      'student_name': studentName,
      'student_code': studentCode,
      'attended_at': attendedAt,
      'is_synced': isSynced ? 1 : 0,
      'is_make_up': isMakeUp ? 1 : 0,
    };
  }
}
