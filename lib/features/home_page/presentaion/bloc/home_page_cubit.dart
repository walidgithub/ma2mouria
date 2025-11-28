import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ma2mouria/features/home_page/data/requests/add_member_request.dart';
import 'package:ma2mouria/features/home_page/data/requests/delete_member_request.dart';
import 'package:ma2mouria/features/home_page/data/requests/get_head_report_request.dart';
import 'package:ma2mouria/features/home_page/data/requests/reset_rule_request.dart';
import 'package:ma2mouria/features/home_page/data/requests/update_rule_request.dart';
import 'package:ma2mouria/features/home_page/domain/usecases/add_round_usecase.dart';
import 'package:ma2mouria/features/home_page/domain/usecases/add_receipt_usecase.dart';
import 'package:ma2mouria/features/home_page/domain/usecases/delete_round_usecase.dart';
import 'package:ma2mouria/features/home_page/domain/usecases/delete_item_in_member_report_usecase.dart';
import 'package:ma2mouria/features/home_page/domain/usecases/delete_receipt_usecase.dart';
import 'package:ma2mouria/features/home_page/domain/usecases/delete_share_usecase.dart';
import 'package:ma2mouria/features/home_page/domain/usecases/edit_share_usecase.dart';
import 'package:ma2mouria/features/home_page/domain/usecases/get_active_round_usecase.dart';
import 'package:ma2mouria/features/home_page/domain/usecases/get_all_users_usecase.dart';
import 'package:ma2mouria/features/home_page/domain/usecases/get_receipts_usecase.dart';
import 'package:ma2mouria/features/home_page/domain/usecases/get_members_usecase.dart';
import 'package:ma2mouria/features/home_page/domain/usecases/get_users_usecase.dart';
import 'package:ma2mouria/features/home_page/domain/usecases/get_zones_usecase.dart';
import 'package:ma2mouria/features/home_page/domain/usecases/reset_rule_usecase.dart';
import 'package:ma2mouria/features/home_page/domain/usecases/update_rule_usecase.dart';
import 'package:ma2mouria/features/home_page/domain/usecases/upload_image_usecase.dart';
import '../../../../core/base_usecase/firebase_base_usecase.dart';
import '../../../home_page/domain/usecases/logout_usecase.dart';
import '../../data/model/round_model.dart';
import '../../data/requests/add_receipt_request.dart';
import '../../data/requests/delete_round_request.dart';
import '../../data/requests/delete_receipt_request.dart';
import '../../data/requests/delete_share_request.dart';
import '../../data/requests/edit_share_request.dart';
import '../../data/requests/get_active_round_request.dart';
import '../../data/requests/get_members_request.dart';
import '../../data/requests/get_receipts_request.dart';
import '../../data/requests/member_report_request.dart';
import '../../domain/usecases/add_member_usecase.dart';
import '../../domain/usecases/delete_member_usecase.dart';
import '../../domain/usecases/get_head_report_usecase.dart';
import '../../domain/usecases/get_member_report_usecase.dart';
import '../../domain/usecases/get_rule_usecase.dart';
import 'home_page_state.dart';

class HomePageCubit extends Cubit<HomePageState> {
  HomePageCubit(this.logoutUseCase, this.uploadImageUseCase, this.updateRuleUseCase, this.resetRuleUseCase, this.getZonesUseCase, this.getAllUsersUseCase, this.deleteItemInMemberReportUseCase,this.getHeadReportUseCase,this.getMemberReportUseCase,this.deleteReceiptUseCase,this.getReceiptsUseCase,this.addReceiptUseCase,this.getRuleUseCase, this.addRoundUseCase, this.getActiveRoundUseCase, this.deleteRoundUseCase, this.deleteMemberUseCase, this.addMemberUseCase, this.getMembersUseCase, this.getUsersUseCase, this.editShareUseCase, this.deleteShareUseCase) : super(HomePageInitial());
  
  final LogoutUseCase logoutUseCase;
  final GetRuleUseCase getRuleUseCase;
  final AddRoundUseCase addRoundUseCase;
  final GetActiveRoundUseCase getActiveRoundUseCase;
  final DeleteRoundUseCase deleteRoundUseCase;
  final DeleteMemberUseCase deleteMemberUseCase;
  final AddMemberUseCase addMemberUseCase;
  final GetMembersUseCase getMembersUseCase;
  final GetUsersUseCase getUsersUseCase;
  final DeleteReceiptUseCase deleteReceiptUseCase;
  final AddReceiptUseCase addReceiptUseCase;
  final GetReceiptsUseCase getReceiptsUseCase;
  final DeleteShareUseCase deleteShareUseCase;
  final EditShareUseCase editShareUseCase;
  final GetHeadReportUseCase getHeadReportUseCase;
  final GetMemberReportUseCase getMemberReportUseCase;
  final DeleteItemInMemberReportUseCase deleteItemInMemberReportUseCase;
  final GetAllUsersUseCase getAllUsersUseCase;
  final GetZonesUseCase getZonesUseCase;
  final UpdateRuleUseCase updateRuleUseCase;
  final ResetRuleUseCase resetRuleUseCase;
  final UploadImageUseCase uploadImageUseCase;

  static HomePageCubit get(context) => BlocProvider.of(context);

  Future<void> getRuleByEmail(String email) async {
    emit(GetRuleByEmailLoadingState());
    final result = await getRuleUseCase.call(email);
    result.fold(
          (failure) => emit(GetRuleByEmailErrorState(failure.message)),
          (rules) => emit(GetRuleByEmailSuccessState(rules)),
    );
  }

  Future<void> getActiveRound() async {
    emit(GetActiveRoundLoadingState());
    final result = await getActiveRoundUseCase.call(const FirebaseNoParameters());
    result.fold(
          (failure) => emit(GetActiveRoundErrorState(failure.message)),
          (activeRounds) => emit(GetActiveRoundSuccessState(activeRounds)),
    );
  }

  Future<void> getZones() async {
    emit(GetZonesLoadingState());
    final result = await getZonesUseCase.call(const FirebaseNoParameters());
    result.fold(
          (failure) => emit(GetZonesErrorState(failure.message)),
          (zones) => emit(GetZonesSuccessState(zones)),
    );
  }

  Future<void> getUsers() async {
    emit(GetUsersLoadingState());
    final result = await getUsersUseCase.call(const FirebaseNoParameters());
    result.fold(
          (failure) => emit(GetUsersErrorState(failure.message)),
          (users) => emit(GetUsersSuccessState(users)),
    );
  }

  Future<void> getAllUsers() async {
    emit(GetAllUsersLoadingState());
    final result = await getAllUsersUseCase.call(const FirebaseNoParameters());
    result.fold(
          (failure) => emit(GetAllUsersErrorState(failure.message)),
          (users) => emit(GetAllUsersSuccessState(users)),
    );
  }

  Future<void> addRound(RoundModel round) async {
    emit(AddRoundLoadingState());
    final result = await addRoundUseCase.call(round);
    result.fold(
          (failure) => emit(AddRoundErrorState(failure.message)),
          (round) => emit(AddRoundSuccessState()),
    );
  }

  Future<void> addMember(AddMemberRequest addMemberRequest) async {
    emit(AddMemberLoadingState());
    final result = await addMemberUseCase.call(addMemberRequest);
    result.fold(
          (failure) => emit(AddMemberErrorState(failure.message)),
          (member) => emit(AddMemberSuccessState()),
    );
  }

  Future<void> deleteRound(DeleteRoundRequest deleteRoundRequest) async {
    emit(DeleteRoundLoadingState());
    final result = await deleteRoundUseCase.call(deleteRoundRequest);
    result.fold(
          (failure) => emit(DeleteRoundErrorState(failure.message)),
          (deleted) => emit(DeleteRoundSuccessState()),
    );
  }

  Future<void> deleteMember(DeleteMemberRequest deleteMemberRequest) async {
    emit(DeleteMemberLoadingState());
    final result = await deleteMemberUseCase.call(deleteMemberRequest);
    result.fold(
          (failure) => emit(DeleteMemberErrorState(failure.message)),
          (deleted) => emit(DeleteMemberSuccessState()),
    );
  }

  Future<void> getMembers(GetMembersRequest getMembersRequest) async {
    emit(GetMembersLoadingState());
    final result = await getMembersUseCase.call(getMembersRequest);
    result.fold(
          (failure) => emit(GetMembersErrorState(failure.message)),
          (members) => emit(GetMembersSuccessState(members)),
    );
  }

  Future<void> addReceipt(AddReceiptRequest addReceiptRequest) async {
    emit(AddReceiptLoadingState());
    final result = await addReceiptUseCase.call(addReceiptRequest);
    result.fold(
          (failure) => emit(AddReceiptErrorState(failure.message)),
          (receiptId) => emit(AddReceiptSuccessState(receiptId)),
    );
  }

  Future<void> deleteReceipt(DeleteReceiptRequest deleteReceiptRequest) async {
    emit(DeleteReceiptLoadingState());
    final result = await deleteReceiptUseCase.call(deleteReceiptRequest);
    result.fold(
          (failure) => emit(DeleteReceiptErrorState(failure.message)),
          (deleted) => emit(DeleteReceiptSuccessState()),
    );
  }

  Future<void> getReceipts(GetReceiptsRequest getReceiptsRequest) async {
    emit(GetReceiptsLoadingState());
    final result = await getReceiptsUseCase.call(getReceiptsRequest);
    result.fold(
          (failure) => emit(GetReceiptsErrorState(failure.message)),
          (receipts) => emit(GetReceiptsSuccessState(receipts)),
    );
  }
  
  Future<void> logout() async {
    emit(LogoutLoadingState());
    final signOutResult = await logoutUseCase.call(
      const FirebaseNoParameters(),
    );
    signOutResult.fold(
      (failure) => emit(LogoutErrorState(failure.message)),
      (loggedOut) => emit(LogoutSuccessState()),
    );
  }

  Future<void> deleteShare(DeleteShareRequest deleteShareRequest) async {
    emit(DeleteShareLoadingState());
    final result = await deleteShareUseCase.call(deleteShareRequest);
    result.fold(
          (failure) => emit(DeleteShareErrorState(failure.message)),
          (deleted) => emit(DeleteShareSuccessState()),
    );
  }

  Future<void> editShare(EditShareRequest editShareRequest) async {
    emit(EditShareLoadingState());
    final result = await editShareUseCase.call(editShareRequest);
    result.fold(
          (failure) => emit(EditShareErrorState(failure.message)),
          (edited) => emit(EditShareSuccessState()),
    );
  }

  Future<void> getHeadReport(GetHeadReportRequest getHeadReportRequest) async {
    emit(GetHeadReportLoadingState());
    final result = await getHeadReportUseCase.call(getHeadReportRequest);
    result.fold(
          (failure) => emit(GetHeadReportErrorState(failure.message)),
          (headReport) => emit(GetHeadReportSuccessState(headReport)),
    );
  }

  Future<void> getMemberReport(MemberReportRequest memberReportRequest) async {
    emit(GetMemberReportLoadingState());
    final result = await getMemberReportUseCase.call(memberReportRequest);
    result.fold(
          (failure) => emit(GetMemberReportErrorState(failure.message)),
          (memberReport) => emit(GetMemberReportSuccessState(memberReport)),
    );
  }

  Future<void> deleteItemInMemberReport(DeleteShareRequest deleteShareRequest) async {
    emit(DeleteItemInMemberReportLoadingState());
    final result = await deleteItemInMemberReportUseCase.call(deleteShareRequest);
    result.fold(
          (failure) => emit(DeleteItemInMemberReportErrorState(failure.message)),
          (deleted) => emit(DeleteItemInMemberReportSuccessState()),
    );
  }

  Future<void> updateRule(UpdateRuleRequest updateRuleRequest) async {
    emit(UpdateRuleLoadingState());
    final result = await updateRuleUseCase.call(updateRuleRequest);
    result.fold(
          (failure) => emit(UpdateRuleErrorState(failure.message)),
          (updated) => emit(UpdateRuleSuccessState()),
    );
  }

  Future<void> resetRule(ResetRuleRequest resetRuleRequest) async {
    emit(ResetRuleLoadingState());
    final result = await resetRuleUseCase.call(resetRuleRequest);
    result.fold(
          (failure) => emit(ResetRuleErrorState(failure.message)),
          (reset) => emit(ResetRuleSuccessState()),
    );
  }

  Future<void> uploadImage(String filePath) async {
    emit(UploadImageLoadingState());
    final result = await uploadImageUseCase.call(filePath);
    result.fold(
          (failure) => emit(UploadImageErrorState(failure.message)),
          (uploaded) => emit(UploadImageSuccessState(uploaded)),
    );
  }
}
