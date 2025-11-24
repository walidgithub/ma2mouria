import '../model/receipt_members_model.dart';

class UpdateRuleRequest{
  String email;
  String rule;
  String zone;
  UpdateRuleRequest({required this.email, required this.rule, required this.zone});
}