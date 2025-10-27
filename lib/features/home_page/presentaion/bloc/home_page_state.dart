import 'package:ma2mouria/features/home_page/data/model/cycle_model.dart';
import 'package:ma2mouria/features/home_page/data/model/rules_model.dart';

abstract class HomePageState{}

class HomePageInitial extends HomePageState{}

class GetRuleByEmailSuccessState extends HomePageState{
  final RulesModel rulesModel;

  GetRuleByEmailSuccessState(this.rulesModel);
}
class GetRuleByEmailErrorState extends HomePageState{
  final String errorMessage;

  GetRuleByEmailErrorState(this.errorMessage);
}
class GetRuleByEmailLoadingState extends HomePageState{}
// --------------------------------------------------------
class AddCycleSuccessState extends HomePageState{}
class AddCycleErrorState extends HomePageState{
  final String errorMessage;

  AddCycleErrorState(this.errorMessage);
}
class AddCycleLoadingState extends HomePageState{}
// --------------------------------------------------------
class GetActiveCycleSuccessState extends HomePageState{
  final CycleModel cycleModel;

  GetActiveCycleSuccessState(this.cycleModel);
}
class GetActiveCycleErrorState extends HomePageState{
  final String errorMessage;

  GetActiveCycleErrorState(this.errorMessage);
}
class GetActiveCycleLoadingState extends HomePageState{}
// --------------------------------------------------------
class LogoutSuccessState extends HomePageState{}
class LogoutErrorState extends HomePageState{
  final String errorMessage;

  LogoutErrorState(this.errorMessage);
}
class LogoutLoadingState extends HomePageState{}
// --------------------------------------------------------
class DeleteCycleSuccessState extends HomePageState{}
class DeleteCycleErrorState extends HomePageState{
  final String errorMessage;

  DeleteCycleErrorState(this.errorMessage);
}
class DeleteCycleLoadingState extends HomePageState{}
// --------------------------------------------------------
class AuthNoInternetState extends HomePageState{}