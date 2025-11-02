import 'package:ma2mouria/features/home_page/data/model/cycle_model.dart';
import 'package:ma2mouria/features/home_page/data/model/member_model.dart';
import 'package:ma2mouria/features/home_page/data/model/rules_model.dart';

import '../../data/model/receipt_model.dart';

abstract class HomePageState{}

class HomePageInitial extends HomePageState{}

class GetRuleByEmailSuccessState extends HomePageState{
  final RulesModel rulesModel;

  GetRuleByEmailSuccessState(this.rulesModel);
}
class GetRuleByEmailErrorState extends HomePageState{
  final String errorMessage;

  GetRuleByEmailErrorState(this.errorMessage);
}
class GetRuleByEmailLoadingState extends HomePageState{}
// --------------------------------------------------------
class AddCycleSuccessState extends HomePageState{}
class AddCycleErrorState extends HomePageState{
  final String errorMessage;

  AddCycleErrorState(this.errorMessage);
}
class AddCycleLoadingState extends HomePageState{}
// --------------------------------------------------------
class AddMemberSuccessState extends HomePageState{}
class AddMemberErrorState extends HomePageState{
  final String errorMessage;

  AddMemberErrorState(this.errorMessage);
}
class AddMemberLoadingState extends HomePageState{}
// --------------------------------------------------------
class GetActiveCycleSuccessState extends HomePageState{
  final CycleModel cycleModel;

  GetActiveCycleSuccessState(this.cycleModel);
}
class GetActiveCycleErrorState extends HomePageState{
  final String errorMessage;

  GetActiveCycleErrorState(this.errorMessage);
}
class GetActiveCycleLoadingState extends HomePageState{}
// --------------------------------------------------------
class GetMembersSuccessState extends HomePageState{
  final List<MemberModel> members;

  GetMembersSuccessState(this.members);
}
class GetMembersErrorState extends HomePageState{
  final String errorMessage;

  GetMembersErrorState(this.errorMessage);
}
class GetMembersLoadingState extends HomePageState{}
// --------------------------------------------------------
class GetUsersSuccessState extends HomePageState{
  final List<RulesModel> members;

  GetUsersSuccessState(this.members);
}
class GetUsersErrorState extends HomePageState{
  final String errorMessage;

  GetUsersErrorState(this.errorMessage);
}
class GetUsersLoadingState extends HomePageState{}
// --------------------------------------------------------
class LogoutSuccessState extends HomePageState{}
class LogoutErrorState extends HomePageState{
  final String errorMessage;

  LogoutErrorState(this.errorMessage);
}
class LogoutLoadingState extends HomePageState{}
// --------------------------------------------------------
class DeleteCycleSuccessState extends HomePageState{}
class DeleteCycleErrorState extends HomePageState{
  final String errorMessage;

  DeleteCycleErrorState(this.errorMessage);
}
class DeleteCycleLoadingState extends HomePageState{}
// --------------------------------------------------------
class DeleteMemberSuccessState extends HomePageState{}
class DeleteMemberErrorState extends HomePageState{
  final String errorMessage;

  DeleteMemberErrorState(this.errorMessage);
}
class DeleteMemberLoadingState extends HomePageState{}
// --------------------------------------------------------
class AddReceiptSuccessState extends HomePageState{
  final String receiptId;

  AddReceiptSuccessState(this.receiptId);
}
class AddReceiptErrorState extends HomePageState{
  final String errorMessage;

  AddReceiptErrorState(this.errorMessage);
}
class AddReceiptLoadingState extends HomePageState{}
// --------------------------------------------------------
class GetReceiptsSuccessState extends HomePageState{
  final List<ReceiptModel> receipts;

  GetReceiptsSuccessState(this.receipts);
}
class GetReceiptsErrorState extends HomePageState{
  final String errorMessage;

  GetReceiptsErrorState(this.errorMessage);
}
class GetReceiptsLoadingState extends HomePageState{}
// --------------------------------------------------------
class DeleteReceiptSuccessState extends HomePageState{}
class DeleteReceiptErrorState extends HomePageState{
  final String errorMessage;

  DeleteReceiptErrorState(this.errorMessage);
}
class DeleteReceiptLoadingState extends HomePageState{}
// --------------------------------------------------------
class DeleteShareSuccessState extends HomePageState{}
class DeleteShareErrorState extends HomePageState{
  final String errorMessage;

  DeleteShareErrorState(this.errorMessage);
}
class DeleteShareLoadingState extends HomePageState{}
// --------------------------------------------------------
class EditShareSuccessState extends HomePageState{}
class EditShareErrorState extends HomePageState{
  final String errorMessage;

  EditShareErrorState(this.errorMessage);
}
class EditShareLoadingState extends HomePageState{}
// --------------------------------------------------------
class AuthNoInternetState extends HomePageState{}