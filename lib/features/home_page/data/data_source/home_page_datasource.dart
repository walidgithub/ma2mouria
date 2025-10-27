import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/di/di.dart';
import '../../../../core/utils/constant/app_strings.dart';
import '../model/cycle_model.dart';
import '../model/rules_model.dart';

abstract class BaseDataSource {
  Future<void> logout();
  Future<RulesModel?> getRuleByEmail(String email);
  Future<void> addCycle(CycleModel cycle);
  Future<void> deleteCycle(String cycleName);
  Future<CycleModel> getActiveCycle();
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
  Future<CycleModel> getActiveCycle() async {
    try {
      final query = await firestore
          .collection('cycles')
          .where('active', isEqualTo: true)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        throw AppStrings.noCycleFound;
      }

      return CycleModel.fromJson(query.docs.first.data());
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

  @override
  Future<void> addCycle(CycleModel cycle) async {
    try {
      final collectionRef = firestore.collection('cycles');

      final existing = await collectionRef
          .where('cycle_name', isEqualTo: cycle.cycleName)
          .get();

      if (existing.docs.isNotEmpty) {
        throw Exception('Cycle name "${cycle.cycleName}" already exists.');
      }

      final activeCycles = await collectionRef
          .where('active', isEqualTo: true)
          .get();

      final batch = firestore.batch();
      for (final doc in activeCycles.docs) {
        batch.update(doc.reference, {'active': false});
      }

      final newCycleRef = collectionRef.doc();
      batch.set(newCycleRef, cycle.toJson());

      await batch.commit();
    } on FirebaseException catch (e) {
      throw Exception('Firebase error: ${e.message}');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteCycle(String cycleName) async {
    try {
      final collectionRef = firestore.collection('cycles');

      final querySnapshot =
      await collectionRef.where('cycle_name', isEqualTo: cycleName).get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception('Cycle "$cycleName" not found.');
      }

      for (var doc in querySnapshot.docs) {
        await doc.reference.delete();
      }
    } on FirebaseException catch (e) {
      throw Exception('Firebase error: ${e.message}');
    } catch (e) {
      rethrow;
    }
  }


}