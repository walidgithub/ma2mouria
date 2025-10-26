import 'package:dartz/dartz.dart';

import '../../../../core/firebase/error/firebase_failure.dart';
import '../../data/model/rules_model.dart';

abstract class HomePageRepository {
  Future<Either<FirebaseFailure, void>> logout();
  Future<Either<FirebaseFailure, RulesModel>> getRuleByEmail(String email);
}