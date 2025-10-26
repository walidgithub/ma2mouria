import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ma2mouria/features/auth/presentaion/bloc/auth_state.dart';
import '../../../../core/base_usecase/firebase_base_usecase.dart';
import '../../domain/usecases/login_usecase.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this.loginUseCase) : super(AuthInitial());

  final LoginUseCase loginUseCase;

  static AuthCubit get(context) => BlocProvider.of(context);

  Future<void> login() async {
    emit(LoginLoadingState());
    final result = await loginUseCase.call(const FirebaseNoParameters());
    result.fold(
      (failure) => emit(LoginErrorState(failure.message)),
      (user) => emit(LoginSuccessState(user)),
    );
  }
}
