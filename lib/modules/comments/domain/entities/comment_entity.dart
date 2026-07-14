class CommentStudentEntity {
  final int id;
  final int studentId;
  final String name;
  final String phone;
  final String parentPhone;
  final int classroomId;
  final int centerId;

  CommentStudentEntity({
    required this.id,
    required this.studentId,
    required this.name,
    required this.phone,
    required this.parentPhone,
    required this.classroomId,
    required this.centerId,
  });
}

class CommentEntity {
  final int id;
  final int? videoId;
  final String content;
  final String? image;
  final int studentId;
  final String? replyText;
  final String? replyImage;
  final String? replyVoice;
  final bool isRead;
  final bool liked;
  final String createdAt;
  final CommentStudentEntity student;

  CommentEntity({
    required this.id,
    this.videoId,
    required this.content,
    this.image,
    required this.studentId,
    this.replyText,
    this.replyImage,
    this.replyVoice,
    required this.isRead,
    required this.liked,
    required this.createdAt,
    required this.student,
  });
}

class CommentsPaginationEntity {
  final List<CommentEntity> comments;
  final int currentPage;
  final int lastPage;
  final int total;
  final int perPage;
  final int from;
  final int to;

  CommentsPaginationEntity({
    required this.comments,
    required this.currentPage,
    required this.lastPage,
    required this.total,
    required this.perPage,
    required this.from,
    required this.to,
  });
}
