import 'package:ma2mouria/features/home_page/data/model/expense_model.dart';

class AddExpenseRequest{
  ExpenseModel expense;
  String cycleName;
  AddExpenseRequest({required this.expense, required this.cycleName});
}