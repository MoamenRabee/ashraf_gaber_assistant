import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:samy_mossad_assistant/core/dio_helper.dart';
import 'package:samy_mossad_assistant/modules/auth/domain/usecases/login_usecase.dart';
import 'package:samy_mossad_assistant/modules/auth/domain/usecases/logout_usecase.dart';
import 'package:samy_mossad_assistant/modules/auth/presentation/cubit/auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final LoginUseCase loginUseCase;
  final LogoutUseCase logoutUseCase;

  AuthCubit({required this.loginUseCase, required this.logoutUseCase})
    : super(AuthInitial());

  Future<void> login({required String email, required String password}) async {
    emit(AuthLoading());

    final result = await loginUseCase(email: email, password: password);

    result.fold((error) => emit(AuthError(error)), (user) {
      // إعادة تهيئة DioHelper لإضافة الـ token الجديد
      DioHelper.init();
      emit(AuthLoginSuccess(user));
    });
  }

  Future<void> logout() async {
    emit(AuthLoading());

    final result = await logoutUseCase();

    result.fold((error) => emit(AuthError(error)), (_) {
      // إعادة تهيئة DioHelper لإزالة الـ token
      DioHelper.init();
      emit(AuthLogoutSuccess());
    });
  }
}
