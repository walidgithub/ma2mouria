import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ma2mouria/features/auth/data/model/user_model.dart';
import 'package:ma2mouria/features/home_page/data/model/cycle_model.dart';
import 'package:ma2mouria/features/home_page/data/model/member_model.dart';
import 'package:ma2mouria/features/home_page/data/model/rules_model.dart';
import 'package:ma2mouria/features/home_page/data/model/receipt_model.dart';
import 'package:ma2mouria/features/home_page/data/model/zones_model.dart';
import 'package:ma2mouria/features/home_page/data/requests/add_receipt_request.dart';
import 'package:ma2mouria/features/home_page/data/requests/delete_receipt_request.dart';
import 'package:ma2mouria/features/home_page/data/requests/delete_share_request.dart';
import 'package:ma2mouria/features/home_page/data/requests/edit_share_request.dart';
import 'package:ma2mouria/features/home_page/data/requests/member_report_request.dart';
import 'package:ma2mouria/features/home_page/data/requests/reset_rule_request.dart';
import 'package:ma2mouria/features/home_page/data/requests/update_rule_request.dart';
import 'package:ma2mouria/features/home_page/data/responses/head_report_response.dart';
import 'package:ma2mouria/features/home_page/data/responses/member_report_response.dart';
import '../../../../core/firebase/error/firebase_error_handler.dart';
import '../../../../core/firebase/error/firebase_failure.dart';
import '../../domain/repository/home_page_repository.dart';
import '../data_source/home_page_datasource.dart';
import '../requests/add_member_request.dart';
import '../requests/delete_cycle_request.dart';
import '../requests/delete_member_request.dart';
import '../requests/get_active_cycle_request.dart';
import '../requests/get_head_report_request.dart';
import '../requests/get_members_request.dart';
import '../requests/get_receipts_request.dart';

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
  Future<Either<FirebaseFailure, void>> addCycle(CycleModel cycle) async {
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

  @override
  Future<Either<FirebaseFailure, List<CycleModel>>> getActiveCycle() async {
    try {
      final result = await _homePageDataSource.getActiveCycle();
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
  Future<Either<FirebaseFailure, void>> deleteCycle(DeleteCycleRequest deleteCycleRequest) async {
    try {
      final result = await _homePageDataSource.deleteCycle(deleteCycleRequest);
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
  Future<Either<FirebaseFailure, void>> addMember(AddMemberRequest addMemberRequest) async {
    try {
      final result = await _homePageDataSource.addMember(addMemberRequest);
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
  Future<Either<FirebaseFailure, List<MemberModel>>> getMembers(GetMembersRequest getMembersRequest) async {
    try {
      final result = await _homePageDataSource.getMembers(getMembersRequest);
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
  Future<Either<FirebaseFailure, void>> deleteMember(DeleteMemberRequest deleteMemberRequest) async {
    try {
      final result = await _homePageDataSource.deleteMember(deleteMemberRequest);
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
  Future<Either<FirebaseFailure, List<RulesModel>>> getUsers() async {
    try {
      final result = await _homePageDataSource.getUsers();
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
  Future<Either<FirebaseFailure, String>> addReceipt(AddReceiptRequest addReceiptRequest) async {
    try {
      final result = await _homePageDataSource.addReceipt(addReceiptRequest);
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
  Future<Either<FirebaseFailure, void>> deleteReceipt(DeleteReceiptRequest deleteReceiptRequest) async {
    try {
      final result = await _homePageDataSource.deleteReceipt(deleteReceiptRequest);
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
  Future<Either<FirebaseFailure, List<ReceiptModel>>> getReceipts(GetReceiptsRequest getReceiptsRequest) async {
    try {
      final result = await _homePageDataSource.getReceipts(getReceiptsRequest);
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
  Future<Either<FirebaseFailure, void>> deleteShare(DeleteShareRequest deleteShareRequest) async {
    try {
      final result = await _homePageDataSource.deleteShare(deleteShareRequest);
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
  Future<Either<FirebaseFailure, void>> editShare(EditShareRequest editShareRequest) async {
    try {
      final result = await _homePageDataSource.editShare(editShareRequest);
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
  Future<Either<FirebaseFailure, List<HeadReportResponse>>> getHeadReport(GetHeadReportRequest getHeadReportRequest) async {
    try {
      final result = await _homePageDataSource.getHeadReport(getHeadReportRequest);
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
  Future<Either<FirebaseFailure, List<MemberReportResponse>>> getMemberReport(MemberReportRequest memberReportRequest) async {
    try {
      final result = await _homePageDataSource.getMemberReport(memberReportRequest);
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
  Future<Either<FirebaseFailure, void>> deleteItemInMemberReport(DeleteShareRequest deleteShareRequest) async {
    try {
      final result = await _homePageDataSource.deleteItemInMemberReport(deleteShareRequest);
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
  Future<Either<FirebaseFailure, List<RulesModel>>> getAllUsers() async {
    try {
      final result = await _homePageDataSource.getAllUsers();
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
  Future<Either<FirebaseFailure, List<ZonesModel>>> getZones() async {
    try {
      final result = await _homePageDataSource.getZones();
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
  Future<Either<FirebaseFailure, void>> updateRule(UpdateRuleRequest updateRuleRequest) async {
    try {
      final result = await _homePageDataSource.updateRule(updateRuleRequest);
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
  Future<Either<FirebaseFailure, void>> resetRule(ResetRuleRequest resetRuleRequest) async {
    try {
      final result = await _homePageDataSource.resetRule(resetRuleRequest);
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