import 'package:dartz/dartz.dart';
import 'package:ma2mouria/features/home_page/domain/repository/home_page_repository.dart';

import '../../../../core/base_usecase/firebase_base_usecase.dart';
import '../../../../core/firebase/error/firebase_failure.dart';
import '../../data/model/round_model.dart';

class AddRoundUseCase extends FirebaseBaseUseCase {
  final HomePageRepository homePageRepository;

  AddRoundUseCase(this.homePageRepository);

  @override
  Future<Either<FirebaseFailure, void>> call(parameters) async {
    return await homePageRepository.addRound(parameters);
  }
}