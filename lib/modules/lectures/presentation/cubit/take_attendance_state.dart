import 'package:equatable/equatable.dart';
import 'package:samy_mossad_assistant/modules/lectures/domain/entities/local_attendance_entity.dart';
import 'package:samy_mossad_assistant/modules/lectures/domain/entities/student_absence_entity.dart';
import 'package:samy_mossad_assistant/modules/students/domain/entities/student_entity.dart';

abstract class TakeAttendanceState extends Equatable {
  const TakeAttendanceState();

  @override
  List<Object?> get props => [];
}

class TakeAttendanceInitial extends TakeAttendanceState {}

class TakeAttendanceLoading extends TakeAttendanceState {}

class TakeAttendanceLoaded extends TakeAttendanceState {
  final List<LocalAttendanceEntity> attendanceList;
  final List<StudentEntity> searchResults;
  final String searchQuery;

  /// تواريخ فحص الغياب (yyyy-MM-dd)
  final List<String> checkDates;

  /// أسماء الطلاب اللي بنفحص غيابهم دلوقتي (للتحميل في الخلفية)
  final List<String> checkingAbsenceOf;

  const TakeAttendanceLoaded({
    required this.attendanceList,
    this.searchResults = const [],
    this.searchQuery = '',
    this.checkDates = const [],
    this.checkingAbsenceOf = const [],
  });

  TakeAttendanceLoaded copyWith({
    List<LocalAttendanceEntity>? attendanceList,
    List<StudentEntity>? searchResults,
    String? searchQuery,
    List<String>? checkDates,
    List<String>? checkingAbsenceOf,
    bool clearSearchResults = false,
  }) {
    return TakeAttendanceLoaded(
      attendanceList: attendanceList ?? this.attendanceList,
      searchResults: clearSearchResults
          ? []
          : (searchResults ?? this.searchResults),
      searchQuery: searchQuery ?? this.searchQuery,
      checkDates: checkDates ?? this.checkDates,
      checkingAbsenceOf: checkingAbsenceOf ?? this.checkingAbsenceOf,
    );
  }

  @override
  List<Object?> get props => [
    attendanceList,
    searchResults,
    searchQuery,
    checkDates,
    checkingAbsenceOf,
  ];
}

class TakeAttendanceError extends TakeAttendanceState {
  final String message;

  const TakeAttendanceError(this.message);

  @override
  List<Object?> get props => [message];
}

class TakeAttendanceStudentFound extends TakeAttendanceState {
  final StudentEntity student;

  const TakeAttendanceStudentFound(this.student);

  @override
  List<Object?> get props => [student];
}

class TakeAttendanceStudentNotFound extends TakeAttendanceState {
  final String message;

  const TakeAttendanceStudentNotFound(this.message);

  @override
  List<Object?> get props => [message];
}

class TakeAttendanceSuccess extends TakeAttendanceState {
  final String message;

  const TakeAttendanceSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

/// الطالب غاب في تاريخ من تواريخ الفحص، بيتعرض في popup
class TakeAttendanceAbsenceFound extends TakeAttendanceState {
  final StudentEntity student;
  final StudentAbsenceEntity absence;

  const TakeAttendanceAbsenceFound(this.student, this.absence);

  @override
  List<Object?> get props => [student, absence];
}

class TakeAttendanceAbsenceCheckFailed extends TakeAttendanceState {
  final String message;

  const TakeAttendanceAbsenceCheckFailed(this.message);

  @override
  List<Object?> get props => [message];
}
