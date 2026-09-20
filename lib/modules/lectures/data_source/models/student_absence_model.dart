import 'package:samy_mossad_assistant/modules/lectures/domain/entities/student_absence_entity.dart';

int _toInt(dynamic value) => int.tryParse('$value') ?? 0;

List<String> _toStringList(dynamic value) =>
    (value as List<dynamic>? ?? const []).map((e) => e.toString()).toList();

List<AbsenceLectureEntity> _toLectures(dynamic value) =>
    (value as List<dynamic>? ?? const [])
        .map((e) => AbsenceLectureModel.fromJson(e as Map<String, dynamic>))
        .toList();

class AbsenceLectureModel extends AbsenceLectureEntity {
  const AbsenceLectureModel({
    required super.lectureId,
    required super.description,
    required super.date,
    required super.time,
    required super.centerId,
    required super.lectureStatus,
    required super.status,
    super.attendedAt,
    super.isMakeUp,
    super.notes,
  });

  factory AbsenceLectureModel.fromJson(Map<String, dynamic> json) {
    return AbsenceLectureModel(
      lectureId: _toInt(json['lecture_id']),
      description: json['description']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      time: json['time']?.toString() ?? '',
      centerId: _toInt(json['center_id']),
      lectureStatus: json['lecture_status']?.toString() ?? '',
      status: json['status']?.toString() ?? 'not_recorded',
      attendedAt: json['attended_at']?.toString(),
      isMakeUp: json['is_make_up'] == true || json['is_make_up'] == 1,
      notes: json['notes']?.toString(),
    );
  }
}

class StudentAbsenceModel extends StudentAbsenceEntity {
  const StudentAbsenceModel({
    required super.studentCode,
    required super.studentName,
    required super.hasAbsence,
    super.message,
    super.checkedLectures,
    super.absentDates,
    super.datesWithoutLecture,
    super.history,
    super.historySummary,
  });

  factory StudentAbsenceModel.fromJson(
    Map<String, dynamic> data, {
    String? message,
  }) {
    final student = data['student'] as Map<String, dynamic>? ?? const {};
    final summary = data['history_summary'] as Map<String, dynamic>?;

    return StudentAbsenceModel(
      studentCode: student['student_id']?.toString() ?? '',
      studentName: student['name']?.toString() ?? '',
      hasAbsence: data['has_absence'] == true,
      message: message,
      checkedLectures: _toLectures(data['checked_lectures']),
      absentDates: _toStringList(data['absent_dates']),
      datesWithoutLecture: _toStringList(data['dates_without_lecture']),
      history: _toLectures(data['history']),
      historySummary: summary == null
          ? null
          : HistorySummaryEntity(
              total: _toInt(summary['total']),
              attended: _toInt(summary['attended']),
              notAttended: _toInt(summary['not_attended']),
              notRecorded: _toInt(summary['not_recorded']),
            ),
    );
  }
}
