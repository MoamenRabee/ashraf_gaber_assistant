import 'package:dartz/dartz.dart';
import 'package:samy_mossad_assistant/modules/auth/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<String, UserEntity>> login({
    required String email,
    required String password,
  });

  Future<Either<String, Unit>> logout();
}
