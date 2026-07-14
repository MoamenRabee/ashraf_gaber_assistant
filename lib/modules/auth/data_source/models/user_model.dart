import 'package:samy_mossad_assistant/modules/auth/domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.accessToken,
    required super.name,
    required super.email,
    required super.type,
    required super.canManageLectures,
    required super.canManageLocalExams,
    required super.canManageComments,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final user = json['data']['user'];
    return UserModel(
      id: user['id'] ?? 0,
      accessToken: json['data']['token'] ?? '',
      name: user['name'] ?? '',
      email: user['email'] ?? '',
      type: user['type'] ?? '',
      canManageLectures: user['can_manage_lectures'] ?? false,
      canManageLocalExams: user['can_manage_local_exams'] ?? false,
      canManageComments: user['can_manage_comments'] ?? false,
    );
  }

  factory UserModel.fromCache(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      accessToken: json['access_token'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      type: json['type'] ?? '',
      canManageLectures: json['can_manage_lectures'] ?? false,
      canManageLocalExams: json['can_manage_local_exams'] ?? false,
      canManageComments: json['can_manage_comments'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'access_token': accessToken,
      'name': name,
      'email': email,
      'type': type,
      'can_manage_lectures': canManageLectures,
      'can_manage_local_exams': canManageLocalExams,
      'can_manage_comments': canManageComments,
    };
  }
}
