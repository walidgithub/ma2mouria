import 'package:ma2mouria/features/home_page/data/model/invoice_members_model.dart';

class SpenseModel {
  final String id;
  final String invoiceDetail;
  final double invoiceValue;
  final String invoiceDate;
  final bool shared;
  final String invoiceCreator;
  final List<InvoiceMembersModel> invoiceMembers;

  SpenseModel({
    required this.id,
    required this.invoiceDetail,
    required this.invoiceValue,
    required this.invoiceDate,
    required this.shared,
    required this.invoiceCreator,
    required this.invoiceMembers,
  });

  factory SpenseModel.fromJson(Map<String, dynamic> json) {
    return SpenseModel(
      id: json['id'] ?? '',
      invoiceDetail: json['invoice_detail'] ?? '',
      invoiceValue: (json['invoice_value'] ?? 0).toDouble(),
      invoiceDate: json['invoice_date'] ?? '',
      shared: json['shared'] ?? false,
      invoiceCreator: json['invoice_creator'] ?? '',
      invoiceMembers: (json['invoice_members'] as List<dynamic>? ?? [])
          .map((e) => InvoiceMembersModel.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'invoice_detail': invoiceDetail,
      'invoice_value': invoiceValue,
      'invoice_date': invoiceDate,
      'shared': shared,
      'invoice_creator': invoiceCreator,
      'invoice_members': invoiceMembers.map((e) => e.toJson()).toList(),
    };
  }
}
