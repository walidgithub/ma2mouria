import 'package:dartz/dartz.dart';
import 'package:ma2mouria/features/home_page/data/model/cycle_model.dart';
import 'package:ma2mouria/features/home_page/data/model/rules_model.dart';

import '../../../../core/base_usecase/firebase_base_usecase.dart';
import '../../../../core/firebase/error/firebase_failure.dart';
import '../repository/home_page_repository.dart';

class GetActiveCycleUseCase extends FirebaseBaseUseCase {
  final HomePageRepository homePageRepository;

  GetActiveCycleUseCase(this.homePageRepository);

  @override
  Future<Either<FirebaseFailure, CycleModel>> call(parameters) async {
    return await homePageRepository.getActiveCycle(parameters);
  }
}