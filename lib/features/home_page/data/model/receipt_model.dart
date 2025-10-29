import 'package:ma2mouria/features/home_page/data/model/receipt_members_model.dart';

class ReceiptModel {
  final String id;
  final String receiptDetail;
  final double receiptValue;
  final String receiptDate;
  final bool shared;
  final String receiptCreator;
  final List<ReceiptMembersModel> receiptMembers;

  ReceiptModel({
    required this.id,
    required this.receiptDetail,
    required this.receiptValue,
    required this.receiptDate,
    required this.shared,
    required this.receiptCreator,
    required this.receiptMembers,
  });

  factory ReceiptModel.fromJson(Map<String, dynamic> json) {
    return ReceiptModel(
      id: json['id'] ?? '',
      receiptDetail: json['receipt_detail'] ?? '',
      receiptValue: (json['receipt_value'] ?? 0).toDouble(),
      receiptDate: json['receipt_date'] ?? '',
      shared: json['shared'] ?? false,
      receiptCreator: json['receipt_creator'] ?? '',
      receiptMembers: (json['receipt_members'] as List<dynamic>? ?? [])
          .map((e) => ReceiptMembersModel.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'receipt_detail': receiptDetail,
      'receipt_value': receiptValue,
      'receipt_date': receiptDate,
      'shared': shared,
      'receipt_creator': receiptCreator,
      'receipt_members': receiptMembers.map((e) => e.toJson()).toList(),
    };
  }
}
