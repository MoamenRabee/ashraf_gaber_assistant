import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:samy_mossad_assistant/core/constants.dart';

import 'cache_helper.dart';

class DioHelper {
  static Dio dio = Dio();

  static init() {
    dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: true,
        logPrint: (Object object, {bool isError = false}) {
          log(object.toString());
        },
      ),
    );
    dio.options = BaseOptions(
      baseUrl: Constants.baseUrl,
      sendTimeout: const Duration(minutes: 2),
      queryParameters: {'lang': 'ar'},
      validateStatus: (statusCode) {
        // if ((statusCode ?? 501) < 500) {
        //   return true;
        // }

        return true;
      },
      headers: CacheHelper.getData(key: CacheKeysName.accessToken) == null
          ? null
          : {
              'Authorization':
                  CacheHelper.getData(key: CacheKeysName.accessToken) == null
                  ? null
                  : 'Bearer ${CacheHelper.getData(key: CacheKeysName.accessToken)}',
            },
    );
  }

  static Future<Response> post({
    required String path,
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    Map<String, dynamic>? files,
  }) async {
    if (files != null) {
      FormData formData = FormData.fromMap({...?data as Map<String, dynamic>?});

      if (files.isNotEmpty) {
        for (var entry in files.entries) {
          var file = entry.value;
          formData.files.add(
            MapEntry(
              entry.key,
              await MultipartFile.fromFile(
                file.path,
                filename: file.path.split('/').last,
              ),
            ),
          );
        }
      }

      return dio.post(
        path,
        data: formData,
        queryParameters: queryParameters,
        options: Options(),
      );
    }

    return dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
      options: Options(),
    );
  }

  static Future<Response> put({
    required String path,
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return dio.put(
      path,
      data: data,
      queryParameters: queryParameters,
      options: Options(),
    );
  }

  static Future<Response> delete({
    required String path,
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return dio.delete(
      path,
      data: data,
      queryParameters: queryParameters,
      options: Options(),
    );
  }

  static Future<Response> get({
    required String path,
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) {
    return dio.get(path, data: data, queryParameters: queryParameters);
  }
}
