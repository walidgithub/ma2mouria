import 'package:dartz/dartz.dart';
import 'package:ma2mouria/features/home_page/domain/repository/home_page_repository.dart';
import '../../../../core/base_usecase/firebase_base_usecase.dart';
import '../../../../core/firebase/error/firebase_failure.dart';

class LogoutUseCase extends FirebaseBaseUseCase<void, FirebaseNoParameters> {
  final HomePageRepository homePageRepository;

  LogoutUseCase(this.homePageRepository);

  @override
  Future<Either<FirebaseFailure, void>> call(FirebaseNoParameters parameters) async {
    return await homePageRepository.logout();
  }
}