import 'package:dartz/dartz.dart';
import 'package:samy_mossad_assistant/modules/comments/data_source/comments_remote_data_source.dart';
import 'package:samy_mossad_assistant/modules/comments/domain/entities/comment_entity.dart';
import 'package:samy_mossad_assistant/modules/comments/domain/repository/comments_repository.dart';

class CommentsRepositoryImpl implements CommentsRepository {
  final CommentsRemoteDataSource remoteDataSource;

  CommentsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<String, CommentsPaginationEntity>> getComments({
    String? status,
    int? page,
    int? perPage,
  }) async {
    try {
      final result = await remoteDataSource.getComments(
        status: status,
        page: page,
        perPage: perPage,
      );
      return Right(result);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, CommentEntity>> replyToComment({
    required int commentId,
    String? replyText,
    String? replyImagePath,
    String? replyVoicePath,
    bool? liked,
    bool? isRead,
  }) async {
    try {
      final result = await remoteDataSource.replyToComment(
        commentId: commentId,
        replyText: replyText,
        replyImagePath: replyImagePath,
        replyVoicePath: replyVoicePath,
        liked: liked,
        isRead: isRead,
      );
      return Right(result);
    } catch (e) {
      return Left(e.toString());
    }
  }
}
