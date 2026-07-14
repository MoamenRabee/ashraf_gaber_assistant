import 'package:equatable/equatable.dart';
import 'package:samy_mossad_assistant/modules/lectures/domain/entities/lecture_student_entity.dart';

abstract class LectureStudentsState extends Equatable {
  const LectureStudentsState();

  @override
  List<Object?> get props => [];
}

class LectureStudentsInitial extends LectureStudentsState {}

class LectureStudentsLoading extends LectureStudentsState {}

class LectureStudentsNoInternet extends LectureStudentsState {}

class LectureStudentsLoaded extends LectureStudentsState {
  final List<LectureStudentEntity> students;
  final List<LectureStudentEntity> filteredStudents;
  final String searchQuery;

  const LectureStudentsLoaded({
    required this.students,
    required this.filteredStudents,
    this.searchQuery = '',
  });

  List<LectureStudentEntity> get attendedStudents =>
      filteredStudents.where((s) => s.attendance.isAttended).toList();

  List<LectureStudentEntity> get notAttendedStudents =>
      filteredStudents.where((s) => !s.attendance.isAttended).toList();

  LectureStudentsLoaded copyWith({
    List<LectureStudentEntity>? students,
    List<LectureStudentEntity>? filteredStudents,
    String? searchQuery,
  }) {
    return LectureStudentsLoaded(
      students: students ?? this.students,
      filteredStudents: filteredStudents ?? this.filteredStudents,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [students, filteredStudents, searchQuery];
}

class LectureStudentsError extends LectureStudentsState {
  final String message;

  const LectureStudentsError(this.message);

  @override
  List<Object?> get props => [message];
}
