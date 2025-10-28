import '../model/expense_model.dart';

class DeleteExpenseRequest{
  ExpenseModel expense;
  String cycleName;
  DeleteExpenseRequest({required this.expense, required this.cycleName});
}