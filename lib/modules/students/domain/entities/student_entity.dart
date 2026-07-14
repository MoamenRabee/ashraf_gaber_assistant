import 'package:equatable/equatable.dart';
import 'package:samy_mossad_assistant/modules/students/domain/entities/center_entity.dart';
import 'package:samy_mossad_assistant/modules/students/domain/entities/classroom_entity.dart';

class StudentEntity extends Equatable {
  final int id;
  final int studentId;
  final String name;
  final String phone;
  final String parentPhone;
  final ClassroomEntity classroom;
  final CenterEntity center;

  const StudentEntity({
    required this.id,
    required this.studentId,
    required this.name,
    required this.phone,
    required this.parentPhone,
    required this.classroom,
    required this.center,
  });

  @override
  List<Object?> get props => [
    id,
    studentId,
    name,
    phone,
    parentPhone,
    classroom,
    center,
  ];
}
