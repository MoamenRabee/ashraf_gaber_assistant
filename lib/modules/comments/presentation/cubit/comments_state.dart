import 'package:equatable/equatable.dart';
import 'package:samy_mossad_assistant/modules/comments/domain/entities/comment_entity.dart';

enum CommentFilter { all, unread, read }

abstract class CommentsState extends Equatable {
  const CommentsState();

  @override
  List<Object?> get props => [];
}

class CommentsInitial extends CommentsState {}

class CommentsLoading extends CommentsState {}

class CommentsLoaded extends CommentsState {
  final List<CommentEntity> comments;
  final int currentPage;
  final int lastPage;
  final int total;
  final int totalUnread;
  final int totalRead;
  final CommentFilter filter;

  const CommentsLoaded({
    required this.comments,
    required this.currentPage,
    required this.lastPage,
    required this.total,
    required this.totalUnread,
    required this.totalRead,
    this.filter = CommentFilter.all,
  });

  @override
  List<Object?> get props => [
    comments,
    currentPage,
    lastPage,
    total,
    totalUnread,
    totalRead,
    filter,
  ];

  CommentsLoaded copyWith({
    List<CommentEntity>? comments,
    int? currentPage,
    int? lastPage,
    int? total,
    int? totalUnread,
    int? totalRead,
    CommentFilter? filter,
  }) {
    return CommentsLoaded(
      comments: comments ?? this.comments,
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
      total: total ?? this.total,
      totalUnread: totalUnread ?? this.totalUnread,
      totalRead: totalRead ?? this.totalRead,
      filter: filter ?? this.filter,
    );
  }
}

class CommentsError extends CommentsState {
  final String message;

  const CommentsError(this.message);

  @override
  List<Object?> get props => [message];
}

class CommentsNoInternet extends CommentsState {}

class CommentReplyLoading extends CommentsState {}

class CommentReplySuccess extends CommentsState {
  final CommentEntity updatedComment;

  const CommentReplySuccess(this.updatedComment);

  @override
  List<Object?> get props => [updatedComment];
}

class CommentReplyError extends CommentsState {
  final String message;

  const CommentReplyError(this.message);

  @override
  List<Object?> get props => [message];
}
