import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ma2mouria/features/auth/presentaion/bloc/auth_state.dart';
import '../../../../core/base_usecase/firebase_base_usecase.dart';
import '../../../home_page/domain/usecases/logout_usecase.dart';
import '../../domain/usecases/get_rule_usecase.dart';
import 'home_page_state.dart';

class HomePageCubit extends Cubit<HomePageState> {
  HomePageCubit(this.logoutUseCase,this.getRuleUseCase) : super(HomePageInitial());
  
  final LogoutUseCase logoutUseCase;
  final GetRuleUseCase getRuleUseCase;

  static HomePageCubit get(context) => BlocProvider.of(context);

  Future<void> getRuleByEmail(String email) async {
    emit(GetRuleByEmailLoadingState());
    final result = await getRuleUseCase.call(email);
    result.fold(
          (failure) => emit(GetRuleByEmailErrorState(failure.message)),
          (rules) => emit(GetRuleByEmailSuccessState(rules)),
    );
  }
  
  Future<void> logout() async {
    emit(LogoutLoadingState());
    final signOutResult = await logoutUseCase.call(
      const FirebaseNoParameters(),
    );
    signOutResult.fold(
      (failure) => emit(LogoutErrorState(failure.message)),
      (loggedOut) => emit(LogoutSuccessState()),
    );
  }
}
