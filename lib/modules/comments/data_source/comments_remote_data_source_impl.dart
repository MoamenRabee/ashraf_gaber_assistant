import 'dart:io';
import 'package:dio/dio.dart';
import 'package:samy_mossad_assistant/core/constants.dart';
import 'package:samy_mossad_assistant/core/dio_helper.dart';
import 'package:samy_mossad_assistant/modules/comments/data_source/comments_remote_data_source.dart';
import 'package:samy_mossad_assistant/modules/comments/data_source/models/comment_model.dart';
import 'package:samy_mossad_assistant/modules/comments/domain/entities/comment_entity.dart';

class CommentsRemoteDataSourceImpl implements CommentsRemoteDataSource {
  @override
  Future<CommentsPaginationEntity> getComments({
    String? status,
    int? page,
    int? perPage,
  }) async {
    try {
      final response = await DioHelper.get(
        path: Endpoints.getComments(
          status: status,
          page: page,
          perPage: perPage,
        ),
      );

      if (response.data['status'] == true) {
        return CommentsPaginationModel.fromJson(response.data);
      } else {
        throw Exception(response.data['message'] ?? 'فشل في تحميل التعليقات');
      }
    } catch (e) {
      throw Exception('فشل في تحميل التعليقات: ${e.toString()}');
    }
  }

  @override
  Future<CommentEntity> replyToComment({
    required int commentId,
    String? replyText,
    String? replyImagePath,
    String? replyVoicePath,
    bool? liked,
    bool? isRead,
  }) async {
    try {
      // إنشاء FormData
      Map<String, dynamic> formDataMap = {};

      if (replyText != null) {
        formDataMap['reply_text'] = replyText;
      }

      if (replyImagePath != null) {
        formDataMap['reply_image'] = await MultipartFile.fromFile(
          replyImagePath,
          filename: replyImagePath.split('/').last,
        );
      }

      if (replyVoicePath != null) {
        formDataMap['reply_voice'] = await MultipartFile.fromFile(
          replyVoicePath,
          filename: replyVoicePath.split('/').last,
        );
      }

      if (liked != null) {
        formDataMap['liked'] = liked ? '1' : '0';
      }

      if (isRead != null) {
        formDataMap['is_read'] = isRead ? '1' : '0';
      }

      FormData formData = FormData.fromMap(formDataMap);

      final response = await DioHelper.post(
        path: Endpoints.replyToComment(commentId),
        data: formData,
      );

      if (response.data['status'] == 200) {
        return CommentModel.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'فشل في الرد على التعليق');
      }
    } catch (e) {
      throw Exception('فشل في الرد على التعليق: ${e.toString()}');
    }
  }
}
