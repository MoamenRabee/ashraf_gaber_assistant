import 'package:equatable/equatable.dart';

class ClassroomEntity extends Equatable {
  final int id;
  final String name;

  const ClassroomEntity({required this.id, required this.name});

  @override
  List<Object?> get props => [id, name];
}
