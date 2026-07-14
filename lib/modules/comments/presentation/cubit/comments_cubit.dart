import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:samy_mossad_assistant/modules/comments/domain/usecases/get_comments_usecase.dart';
import 'package:samy_mossad_assistant/modules/comments/domain/usecases/reply_to_comment_usecase.dart';
import 'package:samy_mossad_assistant/modules/comments/presentation/cubit/comments_state.dart';

class CommentsCubit extends Cubit<CommentsState> {
  final GetCommentsUseCase getCommentsUseCase;
  final ReplyToCommentUseCase replyToCommentUseCase;

  CommentsCubit({
    required this.getCommentsUseCase,
    required this.replyToCommentUseCase,
  }) : super(CommentsInitial());

  int _totalUnread = 0;
  int _totalRead = 0;

  Future<void> loadComments({
    CommentFilter filter = CommentFilter.all,
    int page = 1,
  }) async {
    if (page == 1) {
      emit(CommentsLoading());
    }

    // Check internet connectivity
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      emit(CommentsNoInternet());
      return;
    }

    String? statusParam;
    if (filter == CommentFilter.unread) {
      statusParam = 'unread';
    } else if (filter == CommentFilter.read) {
      statusParam = 'read';
    }

    final result = await getCommentsUseCase(
      status: statusParam,
      page: page,
      perPage: 20,
    );

    result.fold((error) => emit(CommentsError(error)), (pagination) {
      // Calculate totals only on first page load
      if (page == 1) {
        if (filter == CommentFilter.all) {
          _totalUnread = pagination.comments.where((c) => !c.isRead).length;
          _totalRead = pagination.comments.where((c) => c.isRead).length;
        }
      }

      emit(
        CommentsLoaded(
          comments: pagination.comments,
          currentPage: pagination.currentPage,
          lastPage: pagination.lastPage,
          total: pagination.total,
          totalUnread: _totalUnread,
          totalRead: _totalRead,
          filter: filter,
        ),
      );
    });
  }

  Future<void> loadMoreComments() async {
    if (state is! CommentsLoaded) return;

    final currentState = state as CommentsLoaded;
    if (currentState.currentPage >= currentState.lastPage) return;

    final nextPage = currentState.currentPage + 1;

    String? statusParam;
    if (currentState.filter == CommentFilter.unread) {
      statusParam = 'unread';
    } else if (currentState.filter == CommentFilter.read) {
      statusParam = 'read';
    }

    final result = await getCommentsUseCase(
      status: statusParam,
      page: nextPage,
      perPage: 20,
    );

    result.fold(
      (error) {}, // Ignore error on load more
      (pagination) {
        final allComments = [...currentState.comments, ...pagination.comments];
        emit(
          currentState.copyWith(
            comments: allComments,
            currentPage: pagination.currentPage,
          ),
        );
      },
    );
  }

  void changeFilter(CommentFilter filter) {
    loadComments(filter: filter);
  }

  Future<void> refreshComments() async {
    if (state is CommentsLoaded) {
      final currentState = state as CommentsLoaded;
      await loadComments(filter: currentState.filter);
    } else {
      await loadComments();
    }
  }

  Future<void> replyToComment({
    required int commentId,
    String? replyText,
    String? replyImagePath,
    String? replyVoicePath,
    bool? liked,
    bool? isRead,
  }) async {
    // Save current state before changing it
    final previousState = state is CommentsLoaded
        ? state as CommentsLoaded
        : null;

    emit(CommentReplyLoading());

    // Check internet connectivity
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      emit(const CommentReplyError('لا يوجد اتصال بالإنترنت'));
      // Return to previous state
      if (previousState != null) {
        emit(previousState);
      }
      return;
    }

    final result = await replyToCommentUseCase(
      commentId: commentId,
      replyText: replyText,
      replyImagePath: replyImagePath,
      replyVoicePath: replyVoicePath,
      liked: liked,
      isRead: isRead,
    );

    await result.fold(
      (error) async {
        emit(CommentReplyError(error));
        // Wait a bit for the error to be shown
        await Future.delayed(const Duration(milliseconds: 100));
        // Return to previous state
        if (previousState != null) {
          emit(previousState);
        }
      },
      (updatedComment) async {
        // Show success state briefly for the listener to catch it
        emit(CommentReplySuccess(updatedComment));

        // Wait a tiny bit to ensure the listener catches the success state
        await Future.delayed(const Duration(milliseconds: 100));

        // Update the comment in the current list and return to loaded state
        if (previousState != null) {
          final updatedComments = previousState.comments.map((comment) {
            if (comment.id == updatedComment.id) {
              return updatedComment;
            }
            return comment;
          }).toList();

          // Emit the updated loaded state
          emit(previousState.copyWith(comments: updatedComments));
        }
      },
    );
  }
}
