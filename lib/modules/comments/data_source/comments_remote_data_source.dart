import 'package:samy_mossad_assistant/modules/comments/domain/entities/comment_entity.dart';

abstract class CommentsRemoteDataSource {
  Future<CommentsPaginationEntity> getComments({
    String? status,
    int? page,
    int? perPage,
  });

  Future<CommentEntity> replyToComment({
    required int commentId,
    String? replyText,
    String? replyImagePath,
    String? replyVoicePath,
    bool? liked,
    bool? isRead,
  });
}
