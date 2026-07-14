import 'package:dartz/dartz.dart';
import 'package:samy_mossad_assistant/modules/comments/domain/entities/comment_entity.dart';
import 'package:samy_mossad_assistant/modules/comments/domain/repository/comments_repository.dart';

class ReplyToCommentUseCase {
  final CommentsRepository repository;

  ReplyToCommentUseCase({required this.repository});

  Future<Either<String, CommentEntity>> call({
    required int commentId,
    String? replyText,
    String? replyImagePath,
    String? replyVoicePath,
    bool? liked,
    bool? isRead,
  }) async {
    return await repository.replyToComment(
      commentId: commentId,
      replyText: replyText,
      replyImagePath: replyImagePath,
      replyVoicePath: replyVoicePath,
      liked: liked,
      isRead: isRead,
    );
  }
}
