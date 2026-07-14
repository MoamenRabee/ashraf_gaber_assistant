import 'package:equatable/equatable.dart';
import 'package:samy_mossad_assistant/modules/auth/domain/entities/user_entity.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthLoginSuccess extends AuthState {
  final UserEntity user;

  const AuthLoginSuccess(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthLogoutSuccess extends AuthState {}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}
