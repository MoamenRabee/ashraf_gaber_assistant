import 'package:dartz/dartz.dart';
import 'package:samy_mossad_assistant/modules/auth/domain/repository/auth_repository.dart';

class LogoutUseCase {
  final AuthRepository repository;

  LogoutUseCase(this.repository);

  Future<Either<String, Unit>> call() async {
    return await repository.logout();
  }
}
