import 'package:dartz/dartz.dart';

import '../../../../core/firebase/error/firebase_failure.dart';
import '../../data/model/cycle_model.dart';
import '../../data/model/rules_model.dart';

abstract class HomePageRepository {
  Future<Either<FirebaseFailure, void>> logout();
  Future<Either<FirebaseFailure, RulesModel>> getRuleByEmail(String email);
  Future<Either<FirebaseFailure, void>> addCycle(CycleModel cycle);
  Future<Either<FirebaseFailure, void>> deleteCycle(String cycleName);
  Future<Either<FirebaseFailure, CycleModel>> getActiveCycle();
}