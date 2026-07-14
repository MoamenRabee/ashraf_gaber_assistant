import 'package:dio/dio.dart';
import 'package:samy_mossad_assistant/core/cache_helper.dart';
import 'package:samy_mossad_assistant/core/constants.dart';
import 'package:samy_mossad_assistant/core/dio_helper.dart';
import 'package:samy_mossad_assistant/modules/auth/data_source/auth_remote_data_source.dart';
import 'package:samy_mossad_assistant/modules/auth/data_source/models/user_model.dart';
import 'dart:convert';

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final Response response = await DioHelper.post(
        path: Endpoints.login,
        data: {'email': email, 'password': password},
      );

      // التحقق من نجاح العملية
      if (response.data['status'] == true &&
          response.data['statusCode'] == 200) {
        final userModel = UserModel.fromJson(response.data);

        // حفظ بيانات المستخدم في cache
        await CacheHelper.setData(
          key: 'user_data',
          value: jsonEncode(userModel.toJson()),
        );

        return userModel;
      } else {
        // في حالة الفشل، نرجع رسالة الخطأ من الـ API
        throw Exception(response.data['message'] ?? 'فشل تسجيل الدخول');
      }
    } on DioException catch (e) {
      // معالجة أخطاء Dio
      if (e.response != null && e.response?.data != null) {
        throw Exception(e.response?.data['message'] ?? 'حدث خطأ في الاتصال');
      }
      throw Exception('حدث خطأ في الاتصال: ${e.message}');
    } catch (e) {
      throw Exception('حدث خطأ: ${e.toString()}');
    }
  }
}
