import 'package:flutter/material.dart';
import 'package:samy_mossad_assistant/core/cache_helper.dart';
import 'package:samy_mossad_assistant/core/constants.dart';
import 'package:samy_mossad_assistant/core/dio_helper.dart';
import 'package:samy_mossad_assistant/core/injection_container.dart' as di;
import 'package:samy_mossad_assistant/modules/auth/presentation/login_screen.dart';
import 'package:samy_mossad_assistant/modules/settings/presentation/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تهيئة الـ services
  await CacheHelper.init();
  await di.init();
  DioHelper.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // التحقق من وجود token محفوظ
    final String? token = CacheHelper.getData(key: CacheKeysName.accessToken);

    return MaterialApp(
      title: 'Assistant App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      // إذا كان هناك token، اذهب للـ settings، وإلا اذهب للـ login
      home: token != null ? const SettingsScreen() : const LoginScreen(),
      builder: (context, child) =>
          Directionality(textDirection: TextDirection.rtl, child: child!),
    );
  }
}
