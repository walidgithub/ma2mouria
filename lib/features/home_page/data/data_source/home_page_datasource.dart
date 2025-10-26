import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/di/di.dart';
import '../../../../core/utils/constant/app_strings.dart';
import '../model/rules_model.dart';

abstract class BaseDataSource {
  Future<void> logout();
  Future<RulesModel?> getRuleByEmail(String email);
}

class HomePageDataSource extends BaseDataSource {
  final FirebaseAuth auth = sl<FirebaseAuth>();
  final FirebaseFirestore firestore = sl<FirebaseFirestore>();

  @override
  Future<RulesModel> getRuleByEmail(String email) async {
    try {
      final query = await firestore
          .collection('rules')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        throw AppStrings.userNotFound;
      }

      return RulesModel.fromJson(query.docs.first.data());
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    try {
      final user = auth.currentUser;

      if (user != null) {
        await firestore.collection('rules').doc(user.uid).delete();
      }

      await auth.signOut();
    } catch (e) {
      rethrow;
    }
  }
}