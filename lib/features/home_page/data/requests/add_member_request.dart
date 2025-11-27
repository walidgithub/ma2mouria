import 'package:ma2mouria/features/home_page/data/model/member_model.dart';

class AddMemberRequest{
  MemberModel member;
  String roundName;
  String zone;
  AddMemberRequest({required this.member, required this.roundName, required this.zone});
}