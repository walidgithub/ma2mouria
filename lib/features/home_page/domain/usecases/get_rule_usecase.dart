import 'package:dartz/dartz.dart';
import 'package:ma2mouria/features/home_page/data/model/rules_model.dart';

import '../../../../core/base_usecase/firebase_base_usecase.dart';
import '../../../../core/firebase/error/firebase_failure.dart';
import '../repository/home_page_repository.dart';

class GetRuleUseCase extends FirebaseBaseUseCase {
  final HomePageRepository homePageRepository;

  GetRuleUseCase(this.homePageRepository);

  @override
  Future<Either<FirebaseFailure, RulesModel>> call(parameters) async {
    return await homePageRepository.getRuleByEmail(parameters);
  }
}