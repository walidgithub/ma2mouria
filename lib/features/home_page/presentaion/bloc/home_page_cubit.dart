import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ma2mouria/features/auth/presentaion/bloc/auth_state.dart';
import 'package:ma2mouria/features/home_page/domain/usecases/add_cycle_usecase.dart';
import 'package:ma2mouria/features/home_page/domain/usecases/delete_cycle_usecase.dart';
import 'package:ma2mouria/features/home_page/domain/usecases/get_active_cycle_usecase.dart';
import '../../../../core/base_usecase/firebase_base_usecase.dart';
import '../../../home_page/domain/usecases/logout_usecase.dart';
import '../../data/model/cycle_model.dart';
import '../../domain/usecases/get_rule_usecase.dart';
import 'home_page_state.dart';

class HomePageCubit extends Cubit<HomePageState> {
  HomePageCubit(this.logoutUseCase,this.getRuleUseCase, this.addCycleUseCase, this.getActiveCycleUseCase, this.deleteCycleUseCase) : super(HomePageInitial());
  
  final LogoutUseCase logoutUseCase;
  final GetRuleUseCase getRuleUseCase;
  final AddCycleUseCase addCycleUseCase;
  final GetActiveCycleUseCase getActiveCycleUseCase;
  final DeleteCycleUseCase deleteCycleUseCase;

  static HomePageCubit get(context) => BlocProvider.of(context);

  Future<void> getRuleByEmail(String email) async {
    emit(GetRuleByEmailLoadingState());
    final result = await getRuleUseCase.call(email);
    result.fold(
          (failure) => emit(GetRuleByEmailErrorState(failure.message)),
          (rules) => emit(GetRuleByEmailSuccessState(rules)),
    );
  }

  Future<void> getActiveCycle() async {
    emit(GetActiveCycleLoadingState());
    final result = await getActiveCycleUseCase.call(const FirebaseNoParameters());
    result.fold(
          (failure) => emit(GetActiveCycleErrorState(failure.message)),
          (cycle) => emit(GetActiveCycleSuccessState(cycle)),
    );
  }

  Future<void> addCycle(CycleModel cycle) async {
    emit(AddCycleLoadingState());
    final result = await addCycleUseCase.call(cycle);
    result.fold(
          (failure) => emit(AddCycleErrorState(failure.message)),
          (cycle) => emit(AddCycleSuccessState()),
    );
  }

  Future<void> deleteCycle(String cycleName) async {
    emit(DeleteCycleLoadingState());
    final result = await deleteCycleUseCase.call(cycleName);
    result.fold(
          (failure) => emit(DeleteCycleErrorState(failure.message)),
          (deleted) => emit(DeleteCycleSuccessState()),
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
