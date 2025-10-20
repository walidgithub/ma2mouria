import '../../data/model/user_model.dart';

abstract class AuthState{}

class AuthInitial extends AuthState{}

class LoginSuccessState extends AuthState{
  final UserModel user;

  LoginSuccessState(this.user);
}
class LoginErrorState extends AuthState{
  final String errorMessage;

  LoginErrorState(this.errorMessage);
}
class LoginLoadingState extends AuthState{}

class LogoutSuccessState extends AuthState{}
class LogoutErrorState extends AuthState{
  final String errorMessage;

  LogoutErrorState(this.errorMessage);
}
class LogoutLoadingState extends AuthState{}

class AuthNoInternetState extends AuthState{}