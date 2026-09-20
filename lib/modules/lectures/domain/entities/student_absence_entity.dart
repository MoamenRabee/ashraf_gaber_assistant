import 'package:equatable/equatable.dart';

/// حالة الطالب في محاضرة: attended / not_attended / not_recorded
class AbsenceLectureEntity extends Equatable {
  final int lectureId;
  final String description;
  final String date;
  final String time;
  final int centerId;
  final String lectureStatus;
  final String status;
  final String? attendedAt;
  final bool isMakeUp;
  final String? notes;

  const AbsenceLectureEntity({
    required this.lectureId,
    required this.description,
    required this.date,
    required this.time,
    required this.centerId,
    required this.lectureStatus,
    required this.status,
    this.attendedAt,
    this.isMakeUp = false,
    this.notes,
  });

  bool get isAttended => status == 'attended';
  bool get isAbsent => status == 'not_attended';

  @override
  List<Object?> get props => [
    lectureId,
    description,
    date,
    time,
    centerId,
    lectureStatus,
    status,
    attendedAt,
    isMakeUp,
    notes,
  ];
}

class HistorySummaryEntity extends Equatable {
  final int total;
  final int attended;
  final int notAttended;
  final int notRecorded;

  const HistorySummaryEntity({
    required this.total,
    required this.attended,
    required this.notAttended,
    required this.notRecorded,
  });

  @override
  List<Object?> get props => [total, attended, notAttended, notRecorded];
}

class StudentAbsenceEntity extends Equatable {
  final String studentCode;
  final String studentName;
  final bool hasAbsence;
  final String? message;
  final List<AbsenceLectureEntity> checkedLectures;
  final List<String> absentDates;
  final List<String> datesWithoutLecture;
  final List<AbsenceLectureEntity> history;
  final HistorySummaryEntity? historySummary;

  const StudentAbsenceEntity({
    required this.studentCode,
    required this.studentName,
    required this.hasAbsence,
    this.message,
    this.checkedLectures = const [],
    this.absentDates = const [],
    this.datesWithoutLecture = const [],
    this.history = const [],
    this.historySummary,
  });

  @override
  List<Object?> get props => [
    studentCode,
    studentName,
    hasAbsence,
    message,
    checkedLectures,
    absentDates,
    datesWithoutLecture,
    history,
    historySummary,
  ];
}
