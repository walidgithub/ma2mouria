import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ma2mouria/features/home_page/data/model/cycle_model.dart';
import 'package:ma2mouria/features/home_page/data/model/rules_model.dart';
import '../../../../core/firebase/error/firebase_error_handler.dart';
import '../../../../core/firebase/error/firebase_failure.dart';
import '../../domain/repository/home_page_repository.dart';
import '../data_source/home_page_datasource.dart';

class HomePageRepositoryImpl extends HomePageRepository {
  final HomePageDataSource _homePageDataSource;

  HomePageRepositoryImpl(this._homePageDataSource);

  @override
  Future<Either<FirebaseFailure, void>> logout() async {
    try {
      final result = await _homePageDataSource.logout();
      return Right(result);
    } on FirebaseAuthException catch (e) {
      return Left(FirebaseFailure(FirebaseErrorHandler.handleAuthError(e)));
    } on FirebaseException catch (e) {
      return Left(FirebaseFailure(FirebaseErrorHandler.handleFirebaseError(e)));
    } catch (e) {
      return Left(FirebaseFailure(FirebaseErrorHandler.handleGenericError(e)));
    }
  }

  @override
  Future<Either<FirebaseFailure, RulesModel>> getRuleByEmail(String email) async {
    try {
      final result = await _homePageDataSource.getRuleByEmail(email);
      return Right(result);
    } on FirebaseAuthException catch (e) {
      return Left(FirebaseFailure(FirebaseErrorHandler.handleAuthError(e)));
    } on FirebaseException catch (e) {
      return Left(FirebaseFailure(FirebaseErrorHandler.handleFirebaseError(e)));
    } catch (e) {
      return Left(FirebaseFailure(FirebaseErrorHandler.handleGenericError(e)));
    }
  }

  @override
  Future<Either<FirebaseFailure, void>> addCycle(Cycle cycle) async {
    try {
      final result = await _homePageDataSource.addCycle(cycle);
      return Right(result);
    } on FirebaseAuthException catch (e) {
      return Left(FirebaseFailure(FirebaseErrorHandler.handleAuthError(e)));
    } on FirebaseException catch (e) {
      return Left(FirebaseFailure(FirebaseErrorHandler.handleFirebaseError(e)));
    } catch (e) {
      return Left(FirebaseFailure(FirebaseErrorHandler.handleGenericError(e)));
    }
  }
}