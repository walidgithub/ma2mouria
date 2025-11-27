import 'package:ma2mouria/features/home_page/data/model/member_model.dart';
import 'package:ma2mouria/features/home_page/data/model/receipt_model.dart';

class RoundModel {
  final String id;
  final List<MemberModel> members;
  final double memberBudget;
  final int membersCount;
  final String roundDate;
  final List<ReceiptModel> receipts;
  final bool active;
  final String roundName;
  final String zone;

  RoundModel({
    required this.id,
    required this.members,
    required this.memberBudget,
    required this.membersCount,
    required this.roundDate,
    required this.receipts,
    required this.active,
    required this.roundName,
    required this.zone,
  });

  factory RoundModel.fromJson(Map<String, dynamic> json) {
    return RoundModel(
      id: json['id'] ?? '',
      members: (json['members'] as List<dynamic>? ?? [])
          .map((e) => MemberModel.fromJson(e))
          .toList(),
      memberBudget: (json['member_budget'] ?? 0).toDouble(),
      membersCount: json['members_count'] ?? 0,
      roundDate: json['round_date'] ?? '',
      receipts: (json['receipts'] as List<dynamic>? ?? [])
          .map((e) => ReceiptModel.fromJson(e))
          .toList(),
      active: json['active'] ?? false,
      roundName: json['round_name'] ?? '',
      zone: json['zone'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'members': members.map((e) => e.toJson()).toList(),
      'member_budget': memberBudget,
      'members_count': membersCount,
      'round_date': roundDate,
      'receipts': receipts.map((e) => e.toJson()).toList(),
      'active': active,
      'round_name': roundName,
      'zone': zone,
    };
  }
}
