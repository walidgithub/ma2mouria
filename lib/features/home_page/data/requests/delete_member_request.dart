import 'package:ma2mouria/features/home_page/data/model/member_model.dart';

class DeleteMemberRequest{
  MemberModel member;
  String cycleName;
  String zone;
  DeleteMemberRequest({required this.member, required this.cycleName, required this.zone});
}