import 'dart:developer';

import 'package:get_storage/get_storage.dart';

class CacheHelper {
  static GetStorage box = GetStorage();

  static Future<void> init() async {
    await GetStorage.init();
  }

  static Future<void> setString({
    required String key,
    required String value,
  }) async {
    await box.write(key, value).then((val) {
      log("SET => $key : $value");
    });
  }

  static Future<void> setList({
    required String key,
    required List<String> value,
  }) async {
    await box.write(key, value).then((val) {
      log("SET => $key : $value");
    });
  }

  static getData({required String key}) {
    return box.read(key);
  }

  static Future<void> setData({
    required String key,
    required dynamic value,
  }) async {
    await box.write(key, value).then((val) {
      log("SET => $key : $value");
    });
  }

  static removeKey({required String key}) async {
    await box.remove(key);
    log("Removed : $key");
  }
}
