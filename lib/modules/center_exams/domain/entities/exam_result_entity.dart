import 'package:equatable/equatable.dart';

class ExamResultEntity extends Equatable {
  final int id;
  final int localExamId;
  final int studentId;
  final String studentName;
  final int studentCode;
  final String studentPhone;
  final String parentPhone;
  final double mark;
  final String? notes;

  const ExamResultEntity({
    required this.id,
    required this.localExamId,
    required this.studentId,
    required this.studentName,
    required this.studentCode,
    required this.studentPhone,
    required this.parentPhone,
    required this.mark,
    this.notes,
  });

  @override
  List<Object?> get props => [
    id,
    localExamId,
    studentId,
    studentName,
    studentCode,
    studentPhone,
    parentPhone,
    mark,
    notes,
  ];
}
