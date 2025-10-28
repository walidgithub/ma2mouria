import 'package:ma2mouria/features/home_page/data/model/member_model.dart';

class AddMemberRequest{
  MemberModel member;
  String cycleName;
  AddMemberRequest({required this.member, required this.cycleName});
}