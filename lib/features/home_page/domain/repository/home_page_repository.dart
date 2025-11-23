import 'package:dartz/dartz.dart';
import 'package:ma2mouria/features/home_page/data/model/member_model.dart';
import 'package:ma2mouria/features/home_page/data/requests/delete_share_request.dart';
import 'package:ma2mouria/features/home_page/data/responses/member_report_response.dart';

import '../../../../core/firebase/error/firebase_failure.dart';
import '../../data/model/cycle_model.dart';
import '../../data/model/rules_model.dart';
import '../../data/model/receipt_model.dart';
import '../../data/model/zones_model.dart';
import '../../data/requests/add_receipt_request.dart';
import '../../data/requests/add_member_request.dart';
import '../../data/requests/delete_cycle_request.dart';
import '../../data/requests/delete_receipt_request.dart';
import '../../data/requests/delete_member_request.dart';
import '../../data/requests/edit_share_request.dart';
import '../../data/requests/get_head_report_request.dart';
import '../../data/requests/get_members_request.dart';
import '../../data/requests/get_receipts_request.dart';
import '../../data/requests/member_report_request.dart';
import '../../data/responses/head_report_response.dart';

abstract class HomePageRepository {
  Future<Either<FirebaseFailure, void>> logout();
  Future<Either<FirebaseFailure, RulesModel>> getRuleByEmail(String email);
  Future<Either<FirebaseFailure, void>> addCycle(CycleModel cycle);
  Future<Either<FirebaseFailure, void>> deleteCycle(DeleteCycleRequest deleteCycleRequest);
  Future<Either<FirebaseFailure, CycleModel>> getActiveCycle(String zoneName);
  Future<Either<FirebaseFailure, void>> addMember(AddMemberRequest addMemberRequest);
  Future<Either<FirebaseFailure, void>> deleteMember(DeleteMemberRequest deleteMemberRequest);
  Future<Either<FirebaseFailure, List<MemberModel>>> getMembers(GetMembersRequest getMembersRequest);
  Future<Either<FirebaseFailure, List<RulesModel>>> getUsers();
  Future<Either<FirebaseFailure, List<RulesModel>>> getAllUsers();
  Future<Either<FirebaseFailure, List<ZonesModel>>> getZones();
  Future<Either<FirebaseFailure, String>> addReceipt(AddReceiptRequest addReceiptRequest);
  Future<Either<FirebaseFailure,List<ReceiptModel>>> getReceipts(GetReceiptsRequest getReceiptsRequest);
  Future<Either<FirebaseFailure, void>> deleteReceipt(DeleteReceiptRequest deleteReceiptRequest);
  Future<Either<FirebaseFailure, void>> deleteShare(DeleteShareRequest deleteShareRequest);
  Future<Either<FirebaseFailure, void>> editShare(EditShareRequest editShareRequest);
  Future<Either<FirebaseFailure, List<MemberReportResponse>>> getMemberReport(MemberReportRequest memberReportRequest);
  Future<Either<FirebaseFailure, List<HeadReportResponse>>> getHeadReport(GetHeadReportRequest getHeadReportRequest);
  Future<Either<FirebaseFailure, void>> deleteItemInMemberReport(DeleteShareRequest deleteShareRequest);
}