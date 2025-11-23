import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ma2mouria/features/home_page/data/model/receipt_model.dart';

import '../../../../core/di/di.dart';
import '../../../../core/utils/constant/app_strings.dart';
import '../model/cycle_model.dart';
import '../model/member_model.dart';
import '../model/receipt_members_model.dart';
import '../model/rules_model.dart';
import '../model/zones_model.dart';
import '../requests/add_receipt_request.dart';
import '../requests/add_member_request.dart';
import '../requests/delete_cycle_request.dart';
import '../requests/delete_receipt_request.dart';
import '../requests/delete_member_request.dart';
import '../requests/delete_share_request.dart';
import '../requests/edit_share_request.dart';
import '../requests/get_head_report_request.dart';
import '../requests/get_members_request.dart';
import '../requests/get_receipts_request.dart';
import '../requests/member_report_request.dart';
import '../responses/head_report_response.dart';
import '../responses/member_report_response.dart';

abstract class BaseDataSource {
  Future<void> logout();
  Future<RulesModel?> getRuleByEmail(String email);
  Future<void> addCycle(CycleModel cycle);
  Future<void> deleteCycle(DeleteCycleRequest deleteCycleRequest);
  Future<CycleModel> getActiveCycle(String zoneName);
  Future<void> addMember(AddMemberRequest addMemberRequest);
  Future<void> deleteMember(DeleteMemberRequest deleteMemberRequest);
  Future<List<MemberModel>> getMembers(GetMembersRequest getMembersRequest);
  Future<List<RulesModel>> getUsers();
  Future<List<RulesModel>> getAllUsers();
  Future<List<ZonesModel>> getZones();
  Future<String> addReceipt(AddReceiptRequest addReceiptRequest);
  Future<List<ReceiptModel>> getReceipts(GetReceiptsRequest getReceiptsRequest);
  Future<void> deleteReceipt(DeleteReceiptRequest deleteReceiptRequest);
  Future<void> deleteShare(DeleteShareRequest deleteShareRequest);
  Future<void> editShare(EditShareRequest editShareRequest);
  Future<List<MemberReportResponse>> getMemberReport(MemberReportRequest memberReportRequest);
  Future<List<HeadReportResponse>> getHeadReport(GetHeadReportRequest getHeadReportRequest);
  Future<void> deleteItemInMemberReport(DeleteShareRequest deleteShareRequest);
}

class HomePageDataSource extends BaseDataSource {
  final FirebaseAuth auth = sl<FirebaseAuth>();
  final FirebaseFirestore firestore = sl<FirebaseFirestore>();

  // done------------------------
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
    } on FirebaseException catch (e) {
      throw Exception('${AppStrings.firebaseError.tr()} ${e.message}');
    } catch (e) {
      rethrow;
    }
  }

  // done------------------------
  @override
  Future<CycleModel> getActiveCycle(String zoneName) async {
    try {
      final query = await firestore
          .collection('cycles')
          .where('active', isEqualTo: true)
          .where('zone', isEqualTo: zoneName)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        throw AppStrings.noCycleFound;
      }

      return CycleModel.fromJson(query.docs.first.data());
    } on FirebaseException catch (e) {
      throw Exception('${AppStrings.firebaseError.tr()} ${e.message}');
    } catch (e) {
      rethrow;
    }
  }

  // done------------------------
  @override
  Future<void> logout() async {
    try {
      final user = auth.currentUser;

      if (user != null) {
        await firestore.collection('rules').doc(user.uid).delete();
      }

      await auth.signOut();
    } on FirebaseException catch (e) {
      throw Exception('${AppStrings.firebaseError.tr()} ${e.message}');
    } catch (e) {
      rethrow;
    }
  }

  // done------------------------
  @override
  Future<void> addCycle(CycleModel cycle) async {
    try {
      final collectionRef = firestore.collection('cycles');

      final existing = await collectionRef
          .where('cycle_name', isEqualTo: cycle.cycleName)
          .where('zone', isEqualTo: cycle.zone)
          .get();

      if (existing.docs.isNotEmpty) {
        throw Exception('${AppStrings.cycleName.tr()} "${cycle.cycleName}" ${AppStrings.exist.tr()}');
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
      throw Exception('${AppStrings.firebaseError.tr()} ${e.message}');
    } catch (e) {
      rethrow;
    }
  }

  // done------------------------
  @override
  Future<void> deleteCycle(DeleteCycleRequest deleteCycleRequest) async {
    try {
      final collectionRef = firestore.collection('cycles');

      final querySnapshot = await collectionRef
          .where('cycle_name', isEqualTo: deleteCycleRequest.cycleName)
          .where('active', isEqualTo: true)
          .where('zone', isEqualTo: deleteCycleRequest.zone)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception('${AppStrings.cycleName.tr()} "${deleteCycleRequest.cycleName}" ${AppStrings.notFoundOrActiveCycle.tr()}');
      }

      for (var doc in querySnapshot.docs) {
        await doc.reference.delete();
      }
    } on FirebaseException catch (e) {
      throw Exception('${AppStrings.firebaseError.tr()} ${e.message}');
    } catch (e) {
      rethrow;
    }
  }

  // done------------------------
  @override
  Future<void> addMember(AddMemberRequest addMemberRequest) async {
    try {
      final query = await firestore
          .collection('cycles')
          .where('cycle_name', isEqualTo: addMemberRequest.cycleName)
          .where('zone', isEqualTo: addMemberRequest.zone)
          .where('active', isEqualTo: true)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        throw Exception('${AppStrings.cycleName.tr()} "${addMemberRequest.cycleName}" ${AppStrings.notFoundOrActiveCycle.tr()}');
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

      await _updateMemberRule(
        memberEmail: addMemberRequest.member.email,
        cycle: addMemberRequest.cycleName,
        zone: addMemberRequest.zone,
      );
    } on FirebaseException catch (e) {
      throw Exception('${AppStrings.firebaseError.tr()} ${e.message}');
    } catch (e) {
      rethrow;
    }
  }

  // for delete and add member------------------------
  Future<void> _updateMemberRule({
    required String memberEmail,
    required String cycle,
    required String zone,
  }) async {
    try {
      final query = await firestore
          .collection('rules')
          .where('email', isEqualTo: memberEmail)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        throw Exception("${AppStrings.noRuleFound.tr()} $memberEmail");
      }

      final docRef = query.docs.first.reference;

      await docRef.update({
        'cycle': cycle,
        'zone': zone,
      });
    } on FirebaseException catch (e) {
      throw Exception('${AppStrings.firebaseError.tr()} ${e.message}');
    } catch (e) {
      rethrow;
    }
  }


  // done------------------------
  @override
  Future<List<MemberModel>> getMembers(GetMembersRequest getMembersRequest) async {
    try {
      QuerySnapshot<Map<String, dynamic>> query;

      query = await firestore
          .collection('cycles')
          .where('cycle_name', isEqualTo: getMembersRequest.cycleName)
          .where('zone', isEqualTo: getMembersRequest.zone)
          .where('active', isEqualTo: true)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        throw Exception(AppStrings.noActiveCycleNow.tr());
      }

      final cycleData = query.docs.first.data();
      final cycle = CycleModel.fromJson(cycleData);

      return cycle.members;
    } on FirebaseException catch (e) {
      throw Exception('${AppStrings.firebaseError.tr()} ${e.message}');
    } catch (e) {
      rethrow;
    }
  }

  // done------------------------
  @override
  Future<void> deleteMember(DeleteMemberRequest deleteMemberRequest) async {
    try {
      final query = await firestore
          .collection('cycles')
          .where('cycle_name', isEqualTo: deleteMemberRequest.cycleName)
          .where('zone', isEqualTo: deleteMemberRequest.zone)
          .where('active', isEqualTo: true)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        throw Exception(AppStrings.noActiveCycleNow.tr());
      }

      final docRef = query.docs.first.reference;
      final data = query.docs.first.data();

      final cycle = CycleModel.fromJson(data);

      final isMemberExist = cycle.members.any(
        (m) => m.id == deleteMemberRequest.member.id,
      );

      if (!isMemberExist) {
        throw Exception(AppStrings.memberNotFoundInCycle.tr());
      }

      final updatedMembers = cycle.members
          .where((m) => m.id != deleteMemberRequest.member.id)
          .toList();

      await docRef.update({
        'members': updatedMembers.map((e) => e.toJson()).toList(),
      });

      await _updateMemberRule(
        memberEmail: deleteMemberRequest.member.email,
        cycle: "",
        zone: "",
      );
    } on FirebaseException catch (e) {
      throw Exception('${AppStrings.firebaseError.tr()} ${e.message}');
    } catch (e) {
      rethrow;
    }
  }

  // done------------------------
  @override
  Future<List<RulesModel>> getUsers() async {
    try {
      final snapshot = await firestore.collection('rules').get();

      final rulesList = snapshot.docs
          .map((doc) => RulesModel.fromJson(doc.data()))
          .where((rule) => rule.rule != "head")
          .toList();

      return rulesList;
    } on FirebaseException catch (e) {
      throw Exception('${AppStrings.firebaseError.tr()} ${e.message}');
    } catch (e) {
      rethrow;
    }
  }

  // done------------------------
  @override
  Future<String> addReceipt(AddReceiptRequest addReceiptRequest) async {
    try {
      final query = await firestore
          .collection('cycles')
          .where('cycle_name', isEqualTo: addReceiptRequest.cycleName)
          .where('zone', isEqualTo: addReceiptRequest.zone)
          .where('active', isEqualTo: true)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        throw Exception('${AppStrings.cycleName.tr()} "${addReceiptRequest.cycleName}" ${AppStrings.notFoundOrActiveCycle.tr()}');
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
    } on FirebaseException catch (e) {
      throw Exception('${AppStrings.firebaseError.tr()} ${e.message}');
    } catch (e) {
      rethrow;
    }
  }

  // done------------------------
  @override
  Future<List<ReceiptModel>> getReceipts(GetReceiptsRequest getReceiptsRequest) async {
    try {
      QuerySnapshot<Map<String, dynamic>> query;

      query = await firestore
          .collection('cycles')
          .where('cycle_name', isEqualTo: getReceiptsRequest.cycleName)
          .where('zone', isEqualTo: getReceiptsRequest.zone)
          .where('active', isEqualTo: true)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        throw Exception(AppStrings.noActiveCycleNow.tr());
      }

      final cycleData = query.docs.first.data();
      final cycle = CycleModel.fromJson(cycleData);

      return cycle.receipts;
    } on FirebaseException catch (e) {
      throw Exception('${AppStrings.firebaseError.tr()} ${e.message}');
    } catch (e) {
      rethrow;
    }
  }

  // done------------------------
  @override
  Future<void> deleteReceipt(DeleteReceiptRequest deleteReceiptRequest) async {
    try {
      final query = await firestore
          .collection('cycles')
          .where('cycle_name', isEqualTo: deleteReceiptRequest.cycleName)
          .where('zone', isEqualTo: deleteReceiptRequest.zone)
          .where('active', isEqualTo: true)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        throw Exception(AppStrings.noActiveCycleNow.tr());
      }

      final docRef = query.docs.first.reference;
      final data = query.docs.first.data();

      final cycle = CycleModel.fromJson(data);

      final isReceiptExist = cycle.receipts.any(
        (m) => m.receiptId == deleteReceiptRequest.receiptId,
      );

      if (!isReceiptExist) {
        throw Exception('${AppStrings.receiptNotFound.tr()} ${AppStrings.inCycle.tr()}');
      }

      final updatedReceipts = cycle.receipts
          .where((m) => m.receiptId != deleteReceiptRequest.receiptId)
          .toList();

      await docRef.update({
        'receipts': updatedReceipts.map((e) => e.toJson()).toList(),
      });
    } on FirebaseException catch (e) {
      throw Exception('${AppStrings.firebaseError.tr()} ${e.message}');
    } catch (e) {
      rethrow;
    }
  }

  // done------------------------
  @override
  Future<void> deleteShare(DeleteShareRequest deleteShareRequest) async {
    try {
      final query = await firestore
          .collection('cycles')
          .where('active', isEqualTo: true)
          .where('zone', isEqualTo: deleteShareRequest.zone)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        throw Exception(AppStrings.noActiveCycleNow.tr());
      }

      final cycleDoc = query.docs.first;
      final receipts = List<Map<String, dynamic>>.from(
        cycleDoc['receipts'] ?? [],
      );

      final receiptIndex = receipts.indexWhere(
        (r) => r['receipt_id'] == deleteShareRequest.receiptId,
      );

      if (receiptIndex == -1) throw Exception(AppStrings.receiptNotFound.tr());

      final members = List<Map<String, dynamic>>.from(
        receipts[receiptIndex]['receipt_members'] ?? [],
      );

      members.removeWhere(
        (m) => m['id'] == deleteShareRequest.receiptMembersModel.id,
      );

      receipts[receiptIndex]['receipt_members'] = members;

      await cycleDoc.reference.update({'receipts': receipts});
    } on FirebaseException catch (e) {
      throw Exception('${AppStrings.firebaseError.tr()} ${e.message}');
    } catch (e) {
      rethrow;
    }
  }

  // done------------------------
  @override
  Future<void> editShare(EditShareRequest editShareRequest) async {
    try {
      final query = await firestore
          .collection('cycles')
          .where('active', isEqualTo: true)
          .where('zone', isEqualTo: editShareRequest.zone)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        throw Exception(AppStrings.noActiveCycleNow.tr());
      }

      final cycleDoc = query.docs.first;
      final receipts = List<Map<String, dynamic>>.from(
        cycleDoc['receipts'] ?? [],
      );

      final receiptIndex = receipts.indexWhere(
        (r) => r['receipt_id'] == editShareRequest.receiptId,
      );

      if (receiptIndex == -1) throw Exception(AppStrings.receiptNotFound.tr());

      final members = List<Map<String, dynamic>>.from(
        receipts[receiptIndex]['receipt_members'] ?? [],
      );

      final memberIndex = members.indexWhere(
        (m) => m['id'] == editShareRequest.receiptMembersModel.id,
      );

      if (memberIndex == -1) throw Exception(AppStrings.memberNotFoundInReceipt.tr());

      members[memberIndex] = editShareRequest.receiptMembersModel.toJson();
      receipts[receiptIndex]['receipt_members'] = members;

      await cycleDoc.reference.update({'receipts': receipts});
    } on FirebaseException catch (e) {
      throw Exception('${AppStrings.firebaseError.tr()} ${e.message}');
    } catch (e) {
      rethrow;
    }
  }

  // done------------------------
  @override
  Future<List<HeadReportResponse>> getHeadReport(GetHeadReportRequest getHeadReportRequest) async {
    try {
      final query = await firestore
          .collection('cycles')
          .where('active', isEqualTo: true)
          .where('zone', isEqualTo: getHeadReportRequest.zone)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        throw Exception(AppStrings.noActiveCycleNow.tr());
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
    } on FirebaseException catch (e) {
      throw Exception('${AppStrings.firebaseError.tr()} ${e.message}');
    } catch (e) {
      rethrow;
    }
  }

  // done------------------------
  @override
  Future<List<MemberReportResponse>> getMemberReport(MemberReportRequest memberReportRequest) async {
    try {
      final cycleQuery = await firestore
          .collection('cycles')
          .where('active', isEqualTo: true)
          .where('zone', isEqualTo: memberReportRequest.zone)
          .limit(1)
          .get();

      if (cycleQuery.docs.isEmpty) {
        throw Exception(AppStrings.noActiveCycleNow.tr());
      }

      final cycleDoc = cycleQuery.docs.first;
      final data = cycleDoc.data();

      final cycle = CycleModel.fromJson({...data, 'id': cycleDoc.id});

      final List<MemberReportResponse> reports = [];

      for (final receipt in cycle.receipts) {
        for (final member in receipt.receiptMembers) {
          if (member.name == memberReportRequest.name) {
            reports.add(
                MemberReportResponse(
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
    } on FirebaseException catch (e) {
      throw Exception('${AppStrings.firebaseError.tr()} ${e.message}');
    } catch (e) {
      rethrow;
    }
  }

  // done------------------------
  @override
  Future<void> deleteItemInMemberReport(DeleteShareRequest deleteShareRequest) async {
    try {
      final query = await firestore
          .collection('cycles')
          .where('active', isEqualTo: true)
          .where('zone', isEqualTo: deleteShareRequest.zone)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        throw Exception(AppStrings.noActiveCycleNow.tr());
      }

      final cycleDoc = query.docs.first;
      final receipts = List<Map<String, dynamic>>.from(
        cycleDoc['receipts'] ?? [],
      );

      final receiptIndex = receipts.indexWhere(
            (r) => r['receipt_id'] == deleteShareRequest.receiptId,
      );

      if (receiptIndex == -1) throw Exception(AppStrings.receiptNotFound.tr());

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
    } on FirebaseException catch (e) {
      throw Exception('${AppStrings.firebaseError.tr()} ${e.message}');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<RulesModel>> getAllUsers() async {
    try {
      final snapshot = await firestore.collection('rules').get();

      final rulesList = snapshot.docs
          .map((doc) => RulesModel.fromJson(doc.data()))
          .where((rule) => rule.rule != "admin")
          .toList();

      return rulesList;
    } on FirebaseException catch (e) {
      throw Exception('${AppStrings.firebaseError.tr()} ${e.message}');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<ZonesModel>> getZones() async {
    try {
      final snapshot = await firestore.collection('zones').get();

      final zonesList = snapshot.docs
          .map((doc) => ZonesModel.fromJson(doc.data()))
          .toList();

      return zonesList;
    } on FirebaseException catch (e) {
      throw Exception('${AppStrings.firebaseError.tr()} ${e.message}');
    } catch (e) {
      rethrow;
    }
  }
}
