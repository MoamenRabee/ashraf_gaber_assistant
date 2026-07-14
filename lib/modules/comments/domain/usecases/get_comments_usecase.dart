import 'package:dartz/dartz.dart';
import 'package:samy_mossad_assistant/modules/comments/domain/entities/comment_entity.dart';
import 'package:samy_mossad_assistant/modules/comments/domain/repository/comments_repository.dart';

class GetCommentsUseCase {
  final CommentsRepository repository;

  GetCommentsUseCase({required this.repository});

  Future<Either<String, CommentsPaginationEntity>> call({
    String? status,
    int? page,
    int? perPage,
  }) async {
    return await repository.getComments(
      status: status,
      page: page,
      perPage: perPage,
    );
  }
}
