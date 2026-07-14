import 'package:dartz/dartz.dart';
import 'package:samy_mossad_assistant/core/cache_helper.dart';
import 'package:samy_mossad_assistant/core/constants.dart';
import 'package:samy_mossad_assistant/modules/auth/data_source/auth_remote_data_source.dart';
import 'package:samy_mossad_assistant/modules/auth/domain/entities/user_entity.dart';
import 'package:samy_mossad_assistant/modules/auth/domain/repository/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<String, UserEntity>> login({
    required String email,
    required String password,
  }) async {
    try {
      final user = await remoteDataSource.login(
        email: email,
        password: password,
      );

      // حفظ الـ token
      await CacheHelper.setString(
        key: CacheKeysName.accessToken,
        value: user.accessToken,
      );

      return Right(user);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, Unit>> logout() async {
    try {
      await CacheHelper.removeKey(key: CacheKeysName.accessToken);
      await CacheHelper.removeKey(key: 'user_data');
      return const Right(unit);
    } catch (e) {
      return Left(e.toString());
    }
  }
}
