import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final int id;
  final String accessToken;
  final String name;
  final String email;
  final String type;
  final bool canManageLectures;
  final bool canManageLocalExams;
  final bool canManageComments;

  const UserEntity({
    required this.id,
    required this.accessToken,
    required this.name,
    required this.email,
    required this.type,
    required this.canManageLectures,
    required this.canManageLocalExams,
    required this.canManageComments,
  });

  @override
  List<Object?> get props => [
    id,
    accessToken,
    name,
    email,
    type,
    canManageLectures,
    canManageLocalExams,
    canManageComments,
  ];
}
