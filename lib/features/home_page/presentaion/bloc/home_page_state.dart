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

class LogoutSuccessState extends HomePageState{}
class LogoutErrorState extends HomePageState{
  final String errorMessage;

  LogoutErrorState(this.errorMessage);
}
class LogoutLoadingState extends HomePageState{}

class AuthNoInternetState extends HomePageState{}