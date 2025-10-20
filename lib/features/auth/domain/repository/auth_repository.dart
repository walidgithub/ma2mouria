import 'package:dartz/dartz.dart';

import '../../../../core/firebase/error/firebase_failure.dart';
import '../../data/model/user_model.dart';

abstract class AuthRepository {
  Future<Either<FirebaseFailure, UserModel>> login();
  Future<Either<FirebaseFailure, void>> logout();
}