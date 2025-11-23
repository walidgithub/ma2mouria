import 'package:ma2mouria/features/home_page/data/model/member_model.dart';

class AddMemberRequest{
  MemberModel member;
  String cycleName;
  String zone;
  AddMemberRequest({required this.member, required this.cycleName, required this.zone});
}