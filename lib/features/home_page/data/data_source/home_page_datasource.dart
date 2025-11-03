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
import '../requests/delete_share_request.dart';
import '../requests/edit_share_request.dart';
import '../requests/member_report_request.dart';
import '../responses/head_report_response.dart';
import '../responses/member_report_response.dart';

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
  Future<void> deleteShare(DeleteShareRequest deleteShareRequest);
  Future<void> editShare(EditShareRequest editShareRequest);
  Future<List<MemberReportResponse>> getMemberReport(MemberReportRequest memberReportRequest);
  Future<List<HeadReportResponse>> getHeadReport();
  Future<void> deleteItemInMemberReport(DeleteShareRequest deleteShareRequest);
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
          .where('active', isEqualTo: true)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception('Cycle "$cycleName" not found or no active cycle');
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
          .where('active', isEqualTo: true)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        throw Exception('Cycle "${addMemberRequest.cycleName}" not found or no active cycle');
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
          .where('active', isEqualTo: true)
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
          .where('active', isEqualTo: true)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        throw Exception('Cycle not found or no active cycle');
      }

      final docRef = query.docs.first.reference;
      final data = query.docs.first.data();

      final cycle = CycleModel.fromJson(data);

      final isMemberExist = cycle.members.any(
        (m) => m.id == deleteMemberRequest.member.id,
      );

      if (!isMemberExist) {
        throw Exception('Member not found in this cycle');
      }

      final updatedMembers = cycle.members
          .where((m) => m.id != deleteMemberRequest.member.id)
          .toList();

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
          .where('active', isEqualTo: true)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        throw Exception('Cycle "${addReceiptRequest.cycleName}" not found or no active cycle');
      }

      final docRef = query.docs.first.reference;
      final snapshot = await docRef.get();
      final data = snapshot.data();
      final currentReceipts = (data?['receipts'] as List<dynamic>?) ?? [];

      final existingReceiptIndex = currentReceipts.indexWhere(
        (r) => r['receipt_id'] == addReceiptRequest.receipt.receiptId,
      );

      String usedReceiptId = addReceiptRequest.receipt.receiptId;

      if (existingReceiptIndex != -1) {
        final existingReceipt = Map<String, dynamic>.from(
          currentReceipts[existingReceiptIndex],
        );

        final List<dynamic> existingMembers =
            (existingReceipt['receipt_members'] as List<dynamic>? ?? []);

        final members = existingMembers
            .map(
              (m) => ReceiptMembersModel.fromJson(Map<String, dynamic>.from(m)),
            )
            .toList();

        final newMembers = addReceiptRequest.receipt.receiptMembers;

        for (var member in newMembers) {
          final exists = members.any((m) => m.id == member.id);
          if (!exists) members.add(member);
        }

        existingReceipt['receipt_members'] = members
            .map((m) => m.toJson())
            .toList();

        currentReceipts[existingReceiptIndex] = existingReceipt;

        await docRef.update({'receipts': currentReceipts});
      } else {
        await docRef.update({
          'receipts': FieldValue.arrayUnion([
            addReceiptRequest.receipt.toJson(),
          ]),
        });
      }

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
          .where('active', isEqualTo: true)
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
          .where('active', isEqualTo: true)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        throw Exception('Cycle not found or no active cycle');
      }

      final docRef = query.docs.first.reference;
      final data = query.docs.first.data();

      final cycle = CycleModel.fromJson(data);

      final isReceiptExist = cycle.receipts.any(
        (m) => m.id == deleteReceiptRequest.receipt.id,
      );

      if (!isReceiptExist) {
        throw Exception('Receipt not found in this cycle');
      }

      final updatedReceipts = cycle.receipts
          .where((m) => m.id != deleteReceiptRequest.receipt.id)
          .toList();

      await docRef.update({
        'receipts': updatedReceipts.map((e) => e.toJson()).toList(),
      });
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteShare(DeleteShareRequest deleteShareRequest) async {
    try {
      final query = await firestore
          .collection('cycles')
          .where('active', isEqualTo: true)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        throw Exception('No active cycle found');
      }

      final cycleDoc = query.docs.first;
      final receipts = List<Map<String, dynamic>>.from(
        cycleDoc['receipts'] ?? [],
      );

      final receiptIndex = receipts.indexWhere(
        (r) => r['receipt_id'] == deleteShareRequest.receiptId,
      );

      if (receiptIndex == -1) throw Exception('Receipt not found');

      final members = List<Map<String, dynamic>>.from(
        receipts[receiptIndex]['receipt_members'] ?? [],
      );

      members.removeWhere(
        (m) => m['id'] == deleteShareRequest.receiptMembersModel.id,
      );

      receipts[receiptIndex]['receipt_members'] = members;

      await cycleDoc.reference.update({'receipts': receipts});
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> editShare(EditShareRequest editShareRequest) async {
    try {
      final query = await firestore
          .collection('cycles')
          .where('active', isEqualTo: true)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        throw Exception('No active cycle found');
      }

      final cycleDoc = query.docs.first;
      final receipts = List<Map<String, dynamic>>.from(
        cycleDoc['receipts'] ?? [],
      );

      final receiptIndex = receipts.indexWhere(
        (r) => r['receipt_id'] == editShareRequest.receiptId,
      );

      if (receiptIndex == -1) throw Exception('Receipt not found');

      final members = List<Map<String, dynamic>>.from(
        receipts[receiptIndex]['receipt_members'] ?? [],
      );

      final memberIndex = members.indexWhere(
        (m) => m['id'] == editShareRequest.receiptMembersModel.id,
      );

      if (memberIndex == -1) throw Exception('Member not found in receipt');

      members[memberIndex] = editShareRequest.receiptMembersModel.toJson();
      receipts[receiptIndex]['receipt_members'] = members;

      await cycleDoc.reference.update({'receipts': receipts});
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<HeadReportResponse>> getHeadReport() async {
    try {
      final query = await firestore
          .collection('cycles')
          .where('active', isEqualTo: true)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        throw Exception('No active cycle found');
      }

      final cycleDoc = query.docs.first;
      final receipts = List<Map<String, dynamic>>.from(cycleDoc['receipts'] ?? []);

      final Map<String, double> memberTotals = {};

      for (final receipt in receipts) {
        final members =
        List<Map<String, dynamic>>.from(receipt['receipt_members'] ?? []);
        for (final member in members) {
          final name = member['name'] ?? '';
          final shareValue = (member['share_value'] ?? 0).toDouble();

          if (name.isNotEmpty) {
            memberTotals[name] = (memberTotals[name] ?? 0) + shareValue;
          }
        }
      }

      final headReportList = memberTotals.entries
          .map((e) => HeadReportResponse(
        name: e.key,
        leftOf: e.value.toStringAsFixed(2),
      ))
          .toList();

      headReportList.sort((a, b) => double.parse(b.leftOf).compareTo(double.parse(a.leftOf)));

      return headReportList;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<MemberReportResponse>> getMemberReport(MemberReportRequest memberReportRequest) async {
    try {
      final cycleQuery = await firestore
          .collection('cycles')
          .where('active', isEqualTo: true)
          .limit(1)
          .get();

      if (cycleQuery.docs.isEmpty) {
        throw Exception('No active cycle found');
      }

      final cycleDoc = cycleQuery.docs.first;
      final data = cycleDoc.data();

      final cycle = CycleModel.fromJson({...data, 'id': cycleDoc.id});

      final List<MemberReportResponse> reports = [];

      for (final receipt in cycle.receipts) {
        for (final member in receipt.receiptMembers) {
          if (member.name == memberReportRequest.name) {
            reports.add(MemberReportResponse(
              receiptId: receipt.receiptId,
              receiptDetail: receipt.receiptDetail,
              receiptDate: receipt.receiptDate,
              receiptMemberId: member.id,
              name: member.name,
              shareValue: member.shareValue.toStringAsFixed(2),
            ));
          }
        }
      }

      return reports;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteItemInMemberReport(DeleteShareRequest deleteShareRequest) async {
    try {
      final query = await firestore
          .collection('cycles')
          .where('active', isEqualTo: true)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        throw Exception('No active cycle found');
      }

      final cycleDoc = query.docs.first;
      final receipts = List<Map<String, dynamic>>.from(
        cycleDoc['receipts'] ?? [],
      );

      final receiptIndex = receipts.indexWhere(
            (r) => r['receipt_id'] == deleteShareRequest.receiptId,
      );

      if (receiptIndex == -1) throw Exception('Receipt not found');

      final members = List<Map<String, dynamic>>.from(
        receipts[receiptIndex]['receipt_members'] ?? [],
      );

      members.removeWhere(
            (m) => m['id'] == deleteShareRequest.receiptMembersModel.id,
      );

      if (members.isEmpty) {
        receipts.removeAt(receiptIndex);
      } else {
        receipts[receiptIndex]['receipt_members'] = members;
      }

      await cycleDoc.reference.update({'receipts': receipts});

    } catch (e) {
      rethrow;
    }
  }
}
