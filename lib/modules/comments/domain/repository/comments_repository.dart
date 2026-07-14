import 'package:dartz/dartz.dart';
import 'package:samy_mossad_assistant/modules/comments/domain/entities/comment_entity.dart';

abstract class CommentsRepository {
  Future<Either<String, CommentsPaginationEntity>> getComments({
    String? status,
    int? page,
    int? perPage,
  });

  Future<Either<String, CommentEntity>> replyToComment({
    required int commentId,
    String? replyText,
    String? replyImagePath,
    String? replyVoicePath,
    bool? liked,
    bool? isRead,
  });
}
