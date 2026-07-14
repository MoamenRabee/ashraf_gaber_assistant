import 'package:dartz/dartz.dart';
import 'package:samy_mossad_assistant/modules/auth/domain/entities/user_entity.dart';
import 'package:samy_mossad_assistant/modules/auth/domain/repository/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<Either<String, UserEntity>> call({
    required String email,
    required String password,
  }) async {
    return await repository.login(email: email, password: password);
  }
}
