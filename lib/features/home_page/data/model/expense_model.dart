import 'package:ma2mouria/features/home_page/data/model/expense_members_model.dart';

class ExpenseModel {
  final String id;
  final String expenseDetail;
  final double expenseValue;
  final String expenseDate;
  final bool shared;
  final String invoiceCreator;
  final List<ExpenseMembersModel> invoiceMembers;

  ExpenseModel({
    required this.id,
    required this.expenseDetail,
    required this.expenseValue,
    required this.expenseDate,
    required this.shared,
    required this.invoiceCreator,
    required this.invoiceMembers,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['id'] ?? '',
      expenseDetail: json['expense_detail'] ?? '',
      expenseValue: (json['expense_value'] ?? 0).toDouble(),
      expenseDate: json['expense_date'] ?? '',
      shared: json['shared'] ?? false,
      invoiceCreator: json['expense_creator'] ?? '',
      invoiceMembers: (json['expense_members'] as List<dynamic>? ?? [])
          .map((e) => ExpenseMembersModel.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'expense_detail': expenseDetail,
      'expense_value': expenseValue,
      'expense_date': expenseDate,
      'shared': shared,
      'expense_creator': invoiceCreator,
      'expense_members': invoiceMembers.map((e) => e.toJson()).toList(),
    };
  }
}
