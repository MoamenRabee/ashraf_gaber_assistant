import 'package:samy_mossad_assistant/modules/auth/data_source/models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login({required String email, required String password});
}
