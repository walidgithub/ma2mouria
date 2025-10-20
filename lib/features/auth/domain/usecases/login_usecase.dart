import 'package:dartz/dartz.dart';
import '../../../../core/base_usecase/firebase_base_usecase.dart';
import '../../../../core/firebase/error/firebase_failure.dart';
import '../../data/model/user_model.dart';
import '../repository/auth_repository.dart';

class LoginUseCase extends FirebaseBaseUseCase<UserModel, FirebaseNoParameters> {
  final AuthRepository authRepository;

  LoginUseCase(this.authRepository);

  @override
  Future<Either<FirebaseFailure, UserModel>> call(FirebaseNoParameters parameters) async {
    return await authRepository.login();
  }
}