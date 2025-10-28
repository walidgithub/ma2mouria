import 'package:dartz/dartz.dart';
import 'package:ma2mouria/features/home_page/data/model/member_model.dart';

import '../../../../core/firebase/error/firebase_failure.dart';
import '../../data/model/cycle_model.dart';
import '../../data/model/rules_model.dart';
import '../../data/model/expense_model.dart';
import '../../data/requests/add_expense_request.dart';
import '../../data/requests/add_member_request.dart';
import '../../data/requests/delete_expense_request.dart';
import '../../data/requests/delete_member_request.dart';

abstract class HomePageRepository {
  Future<Either<FirebaseFailure, void>> logout();
  Future<Either<FirebaseFailure, RulesModel>> getRuleByEmail(String email);
  Future<Either<FirebaseFailure, void>> addCycle(CycleModel cycle);
  Future<Either<FirebaseFailure, void>> deleteCycle(String cycleName);
  Future<Either<FirebaseFailure, CycleModel>> getActiveCycle();
  Future<Either<FirebaseFailure, void>> addMember(AddMemberRequest addMemberRequest);
  Future<Either<FirebaseFailure, void>> deleteMember(DeleteMemberRequest deleteMemberRequest);
  Future<Either<FirebaseFailure, List<MemberModel>>> getMembers(String cycleName);
  Future<Either<FirebaseFailure, List<RulesModel>>> getUsers();
  Future<Either<FirebaseFailure, void>> addExpense(AddExpenseRequest addExpenseRequest);
  Future<Either<FirebaseFailure,List<ExpenseModel>>> getExpenses(String cycleName);
  Future<Either<FirebaseFailure, void>> deleteExpense(DeleteExpenseRequest deleteExpenseRequest);
}