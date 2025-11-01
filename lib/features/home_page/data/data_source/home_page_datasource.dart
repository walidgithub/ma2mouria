import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ma2mouria/features/home_page/data/model/receipt_model.dart';

import '../../../../core/di/di.dart';
import '../../../../core/utils/constant/app_strings.dart';
import '../model/cycle_model.dart';
import '../model/member_model.dart';
import '../model/receipt_members_model.dart';
import '../model/rules_model.dart';
import '../requests/add_receipt_request.dart';
import '../requests/add_member_request.dart';
import '../requests/delete_receipt_request.dart';
import '../requests/delete_member_request.dart';

abstract class BaseDataSource {
  Future<void> logout();
  Future<RulesModel?> getRuleByEmail(String email);
  Future<void> addCycle(CycleModel cycle);
  Future<void> deleteCycle(String cycleName);
  Future<CycleModel> getActiveCycle();
  Future<void> addMember(AddMemberRequest addMemberRequest);
  Future<void> deleteMember(DeleteMemberRequest deleteMemberRequest);
  Future<List<MemberModel>> getMembers(String cycleName);
  Future<List<RulesModel>> getUsers();
  Future<String> addReceipt(AddReceiptRequest addReceiptRequest);
  Future<List<ReceiptModel>> getReceipts(String cycleName);
  Future<void> deleteReceipt(DeleteReceiptRequest deleteReceiptRequest);
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

      final querySnapshot = await collectionRef
          .where('cycle_name', isEqualTo: cycleName)
          .get();

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

  @override
  Future<void> addMember(AddMemberRequest addMemberRequest) async {
    try {
      final query = await firestore
          .collection('cycles')
          .where('cycle_name', isEqualTo: addMemberRequest.cycleName)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        throw Exception('Cycle "${addMemberRequest.cycleName}" not found');
      }

      final docRef = query.docs.first.reference;

      final snapshot = await docRef.get();
      final data = snapshot.data();
      final currentMembers = (data?['members'] as List<dynamic>?) ?? [];

      final bool exists = currentMembers.any((m) {
        return (m is Map<String, dynamic> &&
            (m['id'] == addMemberRequest.member.id));
      });

      if (exists) {
        await docRef.update({
          'members': FieldValue.arrayRemove([
            currentMembers.firstWhere(
              (m) => m['id'] == addMemberRequest.member.id,
            ),
          ]),
        });
        await docRef.update({
          'members': FieldValue.arrayUnion([addMemberRequest.member.toJson()]),
        });
        return;
      }

      await docRef.update({
        'members': FieldValue.arrayUnion([addMemberRequest.member.toJson()]),
      });
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<MemberModel>> getMembers(String cycleName) async {
    try {
      QuerySnapshot<Map<String, dynamic>> query;

      query = await firestore
          .collection('cycles')
          .where('cycle_name', isEqualTo: cycleName)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        throw Exception('No active or matching cycle found');
      }

      final cycleData = query.docs.first.data();
      final cycle = CycleModel.fromJson(cycleData);

      return cycle.members;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteMember(DeleteMemberRequest deleteMemberRequest) async {
    try {
      final query = await firestore
          .collection('cycles')
          .where('cycle_name', isEqualTo: deleteMemberRequest.cycleName)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        throw Exception('Cycle not found');
      }

      final docRef = query.docs.first.reference;
      final data = query.docs.first.data();

      final cycle = CycleModel.fromJson(data);

      final isMemberExist =
      cycle.members.any((m) => m.id == deleteMemberRequest.member.id);

      if (!isMemberExist) {
        throw Exception('Member not found in this cycle');
      }

      final updatedMembers =
      cycle.members.where((m) => m.id != deleteMemberRequest.member.id).toList();

      await docRef.update({
        'members': updatedMembers.map((e) => e.toJson()).toList(),
      });

    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<RulesModel>> getUsers() async {
    try {
      final snapshot = await firestore.collection('rules').get();

      final rulesList = snapshot.docs
          .map((doc) => RulesModel.fromJson(doc.data()))
          .toList();

      return rulesList;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<String> addReceipt(AddReceiptRequest addReceiptRequest) async {
    try {
      final query = await firestore
          .collection('cycles')
          .where('cycle_name', isEqualTo: addReceiptRequest.cycleName)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        throw Exception('Cycle "${addReceiptRequest.cycleName}" not found');
      }

      final docRef = query.docs.first.reference;
      final snapshot = await docRef.get();
      final data = snapshot.data();
      final currentReceipts = (data?['receipts'] as List<dynamic>?) ?? [];

      // ✅ Try to find existing receipt by receiptId
      final existingReceiptIndex = currentReceipts.indexWhere(
            (r) => r['receipt_id'] == addReceiptRequest.receipt.receiptId,
      );

      String usedReceiptId = addReceiptRequest.receipt.receiptId;

      if (existingReceiptIndex != -1) {
        // ✅ Receipt already exists → just add new member
        final existingReceipt = Map<String, dynamic>.from(
          currentReceipts[existingReceiptIndex],
        );

        final List<dynamic> existingMembers =
        (existingReceipt['receipt_members'] as List<dynamic>? ?? []);

        // Convert to list of ReceiptMembersModel
        final members = existingMembers
            .map((m) => ReceiptMembersModel.fromJson(Map<String, dynamic>.from(m)))
            .toList();

        // Get the new member(s) to add
        final newMembers = addReceiptRequest.receipt.receiptMembers;

        // ✅ Add new members (avoid duplicates by id)
        for (var member in newMembers) {
          final exists = members.any((m) => m.id == member.id);
          if (!exists) members.add(member);
        }

        // Update the receipt_members field
        existingReceipt['receipt_members'] = members.map((m) => m.toJson()).toList();

        // Replace the old receipt in the list
        currentReceipts[existingReceiptIndex] = existingReceipt;

        // ✅ Save all receipts back
        await docRef.update({'receipts': currentReceipts});
      } else {
        // ✅ No existing receipt found → add new receipt
        await docRef.update({
          'receipts': FieldValue.arrayUnion([addReceiptRequest.receipt.toJson()]),
        });
      }

      // ✅ Return the used receiptId (existing or new)
      return usedReceiptId;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<ReceiptModel>> getReceipts(String cycleName) async {
    try {
      QuerySnapshot<Map<String, dynamic>> query;

      query = await firestore
          .collection('cycles')
          .where('cycle_name', isEqualTo: cycleName)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        throw Exception('No active or matching cycle found');
      }

      final cycleData = query.docs.first.data();
      final cycle = CycleModel.fromJson(cycleData);

      return cycle.receipts;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteReceipt(DeleteReceiptRequest deleteReceiptRequest) async {
    try {
      final query = await firestore
          .collection('cycles')
          .where('cycle_name', isEqualTo: deleteReceiptRequest.cycleName)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        throw Exception('Cycle not found');
      }

      final docRef = query.docs.first.reference;
      final data = query.docs.first.data();

      final cycle = CycleModel.fromJson(data);

      final isReceiptExist =
      cycle.receipts.any((m) => m.id == deleteReceiptRequest.receipt.id);

      if (!isReceiptExist) {
        throw Exception('Receipt not found in this cycle');
      }

      final updatedReceipts =
      cycle.receipts.where((m) => m.id != deleteReceiptRequest.receipt.id).toList();

      await docRef.update({
        'receipts': updatedReceipts.map((e) => e.toJson()).toList(),
      });

    } catch (e) {
      rethrow;
    }
  }
}
