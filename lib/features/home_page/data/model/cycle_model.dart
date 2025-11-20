import 'package:ma2mouria/features/home_page/data/model/member_model.dart';
import 'package:ma2mouria/features/home_page/data/model/receipt_model.dart';

class CycleModel {
  final String id;
  final List<MemberModel> members;
  final double memberBudget;
  final int membersCount;
  final String cycleDate;
  final List<ReceiptModel> receipts;
  final bool active;
  final String cycleName;
  final String zone;

  CycleModel({
    required this.id,
    required this.members,
    required this.memberBudget,
    required this.membersCount,
    required this.cycleDate,
    required this.receipts,
    required this.active,
    required this.cycleName,
    required this.zone,
  });

  factory CycleModel.fromJson(Map<String, dynamic> json) {
    return CycleModel(
      id: json['id'] ?? '',
      members: (json['members'] as List<dynamic>? ?? [])
          .map((e) => MemberModel.fromJson(e))
          .toList(),
      memberBudget: (json['member_budget'] ?? 0).toDouble(),
      membersCount: json['members_count'] ?? 0,
      cycleDate: json['cycle_date'] ?? '',
      receipts: (json['receipts'] as List<dynamic>? ?? [])
          .map((e) => ReceiptModel.fromJson(e))
          .toList(),
      active: json['active'] ?? false,
      cycleName: json['cycle_name'] ?? '',
      zone: json['zone'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'members': members.map((e) => e.toJson()).toList(),
      'member_budget': memberBudget,
      'members_count': membersCount,
      'cycle_date': cycleDate,
      'receipts': receipts.map((e) => e.toJson()).toList(),
      'active': active,
      'cycle_name': cycleName,
      'zone': zone,
    };
  }
}
