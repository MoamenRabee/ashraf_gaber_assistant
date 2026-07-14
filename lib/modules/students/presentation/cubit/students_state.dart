import 'package:equatable/equatable.dart';
import 'package:samy_mossad_assistant/modules/students/domain/entities/student_entity.dart';

abstract class StudentsState extends Equatable {
  const StudentsState();

  @override
  List<Object?> get props => [];
}

class StudentsInitial extends StudentsState {}

class StudentsLoading extends StudentsState {}

class StudentsSyncing extends StudentsState {}

class StudentsSearching extends StudentsState {}

class StudentsLoaded extends StudentsState {
  final List<StudentEntity> students;
  final int totalCount;
  final List<Map<String, dynamic>> classrooms;
  final List<Map<String, dynamic>> centers;
  final bool isSearching;

  const StudentsLoaded({
    required this.students,
    required this.totalCount,
    this.classrooms = const [],
    this.centers = const [],
    this.isSearching = false,
  });

  @override
  List<Object?> get props => [
    students,
    totalCount,
    classrooms,
    centers,
    isSearching,
  ];

  StudentsLoaded copyWith({
    List<StudentEntity>? students,
    int? totalCount,
    List<Map<String, dynamic>>? classrooms,
    List<Map<String, dynamic>>? centers,
    bool? isSearching,
  }) {
    return StudentsLoaded(
      students: students ?? this.students,
      totalCount: totalCount ?? this.totalCount,
      classrooms: classrooms ?? this.classrooms,
      centers: centers ?? this.centers,
      isSearching: isSearching ?? this.isSearching,
    );
  }
}

class StudentsSyncSuccess extends StudentsState {
  final int count;
  final String message;

  const StudentsSyncSuccess({required this.count, required this.message});

  @override
  List<Object?> get props => [count, message];
}

class StudentsError extends StudentsState {
  final String message;

  const StudentsError(this.message);

  @override
  List<Object?> get props => [message];
}
