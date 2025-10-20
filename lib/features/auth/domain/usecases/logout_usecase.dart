import 'package:dartz/dartz.dart';
import '../../../../core/base_usecase/firebase_base_usecase.dart';
import '../../../../core/firebase/error/firebase_failure.dart';
import '../repository/auth_repository.dart';

class LogoutUseCase extends FirebaseBaseUseCase<void, FirebaseNoParameters> {
  final AuthRepository authRepository;

  LogoutUseCase(this.authRepository);

  @override
  Future<Either<FirebaseFailure, void>> call(FirebaseNoParameters parameters) async {
    return await authRepository.logout();
  }
}