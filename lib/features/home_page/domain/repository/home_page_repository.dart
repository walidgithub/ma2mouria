import 'package:dartz/dartz.dart';
import 'package:ma2mouria/features/home_page/data/model/member_model.dart';

import '../../../../core/firebase/error/firebase_failure.dart';
import '../../data/model/cycle_model.dart';
import '../../data/model/rules_model.dart';
import '../../data/model/receipt_model.dart';
import '../../data/requests/add_receipt_request.dart';
import '../../data/requests/add_member_request.dart';
import '../../data/requests/delete_receipt_request.dart';
import '../../data/requests/delete_member_request.dart';

abstract class HomePageRepository {
  Future<Either<FirebaseFailure, void>> logout();
  Future<Either<FirebaseFailure, RulesModel>> getRuleByEmail(String email);
  Future<Either<FirebaseFailure, void>> addCycle(CycleModel cycle);
  Future<Either<FirebaseFailure, void>> deleteCycle(String cycleName);
  Future<Either<FirebaseFailure, CycleModel>> getActiveCycle();
  Future<Either<FirebaseFailure, void>> addMember(AddMemberRequest addMemberRequest);
  Future<Either<FirebaseFailure, void>> deleteMember(DeleteMemberRequest deleteMemberRequest);
  Future<Either<FirebaseFailure, List<MemberModel>>> getMembers(String cycleName);
  Future<Either<FirebaseFailure, List<RulesModel>>> getUsers();
  Future<Either<FirebaseFailure, void>> addReceipt(AddReceiptRequest addReceiptRequest);
  Future<Either<FirebaseFailure,List<ReceiptModel>>> getReceipts(String cycleName);
  Future<Either<FirebaseFailure, void>> deleteReceipt(DeleteReceiptRequest deleteReceiptRequest);
}