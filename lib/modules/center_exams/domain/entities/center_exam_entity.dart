import 'package:equatable/equatable.dart';

class CenterExamEntity extends Equatable {
  final int id;
  final String name;
  final int classroomId;
  final String classroomName;
  final int centerId;
  final String centerName;
  final int totalMarks;
  final String createdAt;

  const CenterExamEntity({
    required this.id,
    required this.name,
    required this.classroomId,
    required this.classroomName,
    required this.centerId,
    required this.centerName,
    required this.totalMarks,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    classroomId,
    classroomName,
    centerId,
    centerName,
    totalMarks,
    createdAt,
  ];
}
