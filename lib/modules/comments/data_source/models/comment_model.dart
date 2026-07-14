import 'package:samy_mossad_assistant/modules/comments/domain/entities/comment_entity.dart';

class CommentStudentModel extends CommentStudentEntity {
  CommentStudentModel({
    required super.id,
    required super.studentId,
    required super.name,
    required super.phone,
    required super.parentPhone,
    required super.classroomId,
    required super.centerId,
  });

  factory CommentStudentModel.fromJson(Map<String, dynamic> json) {
    return CommentStudentModel(
      id: json['id'],
      studentId: json['student_id'],
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      parentPhone: json['parent_phone'] ?? '',
      classroomId: json['classroom_id'],
      centerId: json['center_id'],
    );
  }
}

class CommentModel extends CommentEntity {
  CommentModel({
    required super.id,
    super.videoId,
    required super.content,
    super.image,
    required super.studentId,
    super.replyText,
    super.replyImage,
    super.replyVoice,
    required super.isRead,
    required super.liked,
    required super.createdAt,
    required super.student,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'],
      videoId: json['video_id'],
      content: json['content'] ?? '',
      image: json['image'],
      studentId: json['student_id'],
      replyText: json['reply_text'],
      replyImage: json['reply_image'],
      replyVoice: json['reply_voice'],
      isRead: json['is_read'] == 1,
      liked: json['liked'] == 1,
      createdAt: json['created_at'] ?? '',
      student: CommentStudentModel.fromJson(json['student']),
    );
  }
}

class CommentsPaginationModel extends CommentsPaginationEntity {
  CommentsPaginationModel({
    required super.comments,
    required super.currentPage,
    required super.lastPage,
    required super.total,
    required super.perPage,
    required super.from,
    required super.to,
  });

  factory CommentsPaginationModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    final commentsData = data['data'] as List<dynamic>;

    return CommentsPaginationModel(
      comments: commentsData
          .map((comment) => CommentModel.fromJson(comment))
          .toList(),
      currentPage: data['current_page'],
      lastPage: data['last_page'],
      total: data['total'],
      perPage: data['per_page'],
      from: data['from'] ?? 0,
      to: data['to'] ?? 0,
    );
  }
}
