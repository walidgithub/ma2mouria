import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ma2mouria/features/home_page/data/model/receipt_model.dart';
import 'package:ma2mouria/features/home_page/data/requests/reset_rule_request.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/di/di.dart';
import '../../../../core/dio_error/dio_failure.dart';
import '../../../../core/utils/constant/app_constants.dart';
import '../../../../core/utils/constant/app_strings.dart';
import '../model/round_model.dart';
import '../model/member_model.dart';
import '../model/receipt_members_model.dart';
import '../model/rules_model.dart';
import '../model/upload_image_model.dart';
import '../model/zones_model.dart';
import '../requests/add_receipt_request.dart';
import '../requests/add_member_request.dart';
import '../requests/delete_round_request.dart';
import '../requests/delete_receipt_request.dart';
import '../requests/delete_member_request.dart';
import '../requests/delete_share_request.dart';
import '../requests/edit_share_request.dart';
import '../requests/get_active_round_request.dart';
import '../requests/get_head_report_request.dart';
import '../requests/get_members_request.dart';
import '../requests/get_receipts_request.dart';
import '../requests/member_report_request.dart';
import '../requests/update_rule_request.dart';
import '../responses/head_report_response.dart';
import '../responses/member_report_response.dart';

abstract class BaseDataSource {
  Future<void> logout();
  Future<RulesModel?> getRuleByEmail(String email);
  Future<void> addRound(RoundModel round);
  Future<void> deleteRound(DeleteRoundRequest deleteRoundRequest);
  Future<List<RoundModel>> getActiveRound();
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
  Future<void> updateRule(UpdateRuleRequest updateRuleRequest);
  Future<void> resetRule(ResetRuleRequest resetRuleRequest);
  Future<List<MemberReportResponse>> getMemberReport(MemberReportRequest memberReportRequest);
  Future<List<HeadReportResponse>> getHeadReport(GetHeadReportRequest getHeadReportRequest);
  Future<void> deleteItemInMemberReport(DeleteShareRequest deleteShareRequest);
  Future<UploadedImageModel> uploadImage(XFile file);
}

class HomePageDataSource extends BaseDataSource {
  final FirebaseAuth auth = sl<FirebaseAuth>();
  final dio = sl<Dio>();
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
  Future<List<RoundModel>> getActiveRound() async {
    try {
      final query = await firestore
          .collection('rounds')
          .where('active', isEqualTo: true)
          .get();

      if (query.docs.isEmpty) {
        return [];
      }

      return query.docs
          .map((doc) => RoundModel.fromJson(doc.data()))
          .toList();
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
  Future<void> addRound(RoundModel round) async {
    try {
      final collectionRef = firestore.collection('rounds');

      final existing = await collectionRef
          .where('round_name', isEqualTo: round.roundName)
          .where('zone', isEqualTo: round.zone)
          .get();

      if (existing.docs.isNotEmpty) {
        throw Exception('${AppStrings.roundName.tr()} "${round.roundName}" ${AppStrings.exist.tr()}');
      }

      final activeRounds = await collectionRef
          .where('active', isEqualTo: true)
          .where('zone', isEqualTo: round.zone)
          .get();

      final batch = firestore.batch();
      for (final doc in activeRounds.docs) {
        batch.update(doc.reference, {'active': false});
      }

      final newRoundRef = collectionRef.doc();
      batch.set(newRoundRef, round.toJson());

      await batch.commit();
    } on FirebaseException catch (e) {
      throw Exception('${AppStrings.firebaseError.tr()} ${e.message}');
    } catch (e) {
      rethrow;
    }
  }

  // done------------------------
  @override
  Future<void> deleteRound(DeleteRoundRequest deleteRoundRequest) async {
    try {
      final collectionRef = firestore.collection('rounds');

      final querySnapshot = await collectionRef
          .where('round_name', isEqualTo: deleteRoundRequest.roundName)
          .where('active', isEqualTo: true)
          .where('zone', isEqualTo: deleteRoundRequest.zone)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception('${AppStrings.roundName.tr()} "${deleteRoundRequest.roundName}" ${AppStrings.notFoundOrActiveRound.tr()}');
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
          .collection('rounds')
          .where('round_name', isEqualTo: addMemberRequest.roundName)
          .where('zone', isEqualTo: addMemberRequest.zone)
          .where('active', isEqualTo: true)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        throw Exception('${AppStrings.roundName.tr()} "${addMemberRequest.roundName}" ${AppStrings.notFoundOrActiveRound.tr()}');
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
        zone: addMemberRequest.zone,
      );
    } on FirebaseException catch (e) {
      throw Exception('${AppStrings.firebaseError.tr()} ${e.message}');
    } catch (e) {
      rethrow;
    }
  }

  // for adding round and deleting or adding member------------------------
  Future<void> _updateMemberRule({
    required String memberEmail,
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
          .collection('rounds')
          .where('round_name', isEqualTo: getMembersRequest.roundName)
          .where('zone', isEqualTo: getMembersRequest.zone)
          .where('active', isEqualTo: true)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        throw Exception(AppStrings.noActiveRoundNow.tr());
      }

      final roundData = query.docs.first.data();
      final round = RoundModel.fromJson(roundData);

      return round.members;
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
          .collection('rounds')
          .where('round_name', isEqualTo: deleteMemberRequest.roundName)
          .where('zone', isEqualTo: deleteMemberRequest.zone)
          .where('active', isEqualTo: true)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        throw Exception(AppStrings.noActiveRoundNow.tr());
      }

      final docRef = query.docs.first.reference;
      final data = query.docs.first.data();

      final round = RoundModel.fromJson(data);

      final isMemberExist = round.members.any(
        (m) => m.id == deleteMemberRequest.member.id,
      );

      if (!isMemberExist) {
        throw Exception(AppStrings.memberNotFoundInRound.tr());
      }

      final updatedMembers = round.members
          .where((m) => m.id != deleteMemberRequest.member.id)
          .toList();

      await docRef.update({
        'members': updatedMembers.map((e) => e.toJson()).toList(),
      });

      await _updateMemberRule(
        memberEmail: deleteMemberRequest.member.email,
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
          .where((rule) => rule.rule != "admin")
          .where((rule) => rule.zone == "")
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
          .collection('rounds')
          .where('round_name', isEqualTo: addReceiptRequest.roundName)
          .where('zone', isEqualTo: addReceiptRequest.zone)
          .where('active', isEqualTo: true)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        throw Exception('${AppStrings.roundName.tr()} "${addReceiptRequest.roundName}" ${AppStrings.notFoundOrActiveRound.tr()}');
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
          .collection('rounds')
          .where('round_name', isEqualTo: getReceiptsRequest.roundName)
          .where('zone', isEqualTo: getReceiptsRequest.zone)
          .where('active', isEqualTo: true)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        throw Exception(AppStrings.noActiveRoundNow.tr());
      }

      final roundData = query.docs.first.data();
      final round = RoundModel.fromJson(roundData);

      return round.receipts;
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
          .collection('rounds')
          .where('round_name', isEqualTo: deleteReceiptRequest.roundName)
          .where('zone', isEqualTo: deleteReceiptRequest.zone)
          .where('active', isEqualTo: true)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        throw Exception(AppStrings.noActiveRoundNow.tr());
      }

      final docRef = query.docs.first.reference;
      final data = query.docs.first.data();

      final round = RoundModel.fromJson(data);

      final isReceiptExist = round.receipts.any(
        (m) => m.receiptId == deleteReceiptRequest.receiptId,
      );

      if (!isReceiptExist) {
        throw Exception('${AppStrings.receiptNotFound.tr()} ${AppStrings.inRound.tr()}');
      }

      final updatedReceipts = round.receipts
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
          .collection('rounds')
          .where('active', isEqualTo: true)
          .where('zone', isEqualTo: deleteShareRequest.zone)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        throw Exception(AppStrings.noActiveRoundNow.tr());
      }

      final roundDoc = query.docs.first;
      final receipts = List<Map<String, dynamic>>.from(
        roundDoc['receipts'] ?? [],
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

      await roundDoc.reference.update({'receipts': receipts});
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
          .collection('rounds')
          .where('active', isEqualTo: true)
          .where('zone', isEqualTo: editShareRequest.zone)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        throw Exception(AppStrings.noActiveRoundNow.tr());
      }

      final roundDoc = query.docs.first;
      final receipts = List<Map<String, dynamic>>.from(
        roundDoc['receipts'] ?? [],
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

      await roundDoc.reference.update({'receipts': receipts});
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
          .collection('rounds')
          .where('active', isEqualTo: true)
          .where('zone', isEqualTo: getHeadReportRequest.zone)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        throw Exception(AppStrings.noActiveRoundNow.tr());
      }

      final roundDoc = query.docs.first;
      final receipts = List<Map<String, dynamic>>.from(roundDoc['receipts'] ?? []);

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
      final roundQuery = await firestore
          .collection('rounds')
          .where('active', isEqualTo: true)
          .where('zone', isEqualTo: memberReportRequest.zone)
          .limit(1)
          .get();

      if (roundQuery.docs.isEmpty) {
        throw Exception(AppStrings.noActiveRoundNow.tr());
      }

      final roundDoc = roundQuery.docs.first;
      final data = roundDoc.data();

      final round = RoundModel.fromJson({...data, 'id': roundDoc.id});

      final List<MemberReportResponse> reports = [];

      for (final receipt in round.receipts) {
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
          .collection('rounds')
          .where('active', isEqualTo: true)
          .where('zone', isEqualTo: deleteShareRequest.zone)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        throw Exception(AppStrings.noActiveRoundNow.tr());
      }

      final roundDoc = query.docs.first;
      final receipts = List<Map<String, dynamic>>.from(
        roundDoc['receipts'] ?? [],
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

      await roundDoc.reference.update({'receipts': receipts});
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

  @override
  Future<void> updateRule(UpdateRuleRequest updateRuleRequest) async {
    try {
      final query = await firestore
          .collection('rules')
          .where('email', isEqualTo: updateRuleRequest.email)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        final docId = query.docs.first.id;

        await firestore
            .collection('rules')
            .doc(docId)
            .update({'rule': updateRuleRequest.rule,'zone': updateRuleRequest.zone});
      } else {
        throw Exception(AppStrings.noUserWithThisEmail.tr());
      }
    } on FirebaseException catch (e) {
      throw Exception('${AppStrings.firebaseError.tr()} ${e.message}');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> resetRule(ResetRuleRequest resetRuleRequest) async {
    try {
      final query = await firestore
          .collection('rules')
          .where('email', isEqualTo: resetRuleRequest.email)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        final docId = query.docs.first.id;

        await firestore
            .collection('rules')
            .doc(docId)
            .update({'rule': 'user', 'zone': ""});
      } else {
        throw Exception(AppStrings.noUserWithThisEmail.tr());
      }
    } on FirebaseException catch (e) {
      throw Exception('${AppStrings.firebaseError.tr()} ${e.message}');
    } catch (e) {
      rethrow;
    }
  }

  @override
  @override
  Future<UploadedImageModel> uploadImage(XFile file) async {
    try {
      final bytes = await file.readAsBytes();

      final formData = FormData.fromMap({
        "source": MultipartFile.fromBytes(
          bytes,
          filename: file.name,
        ),
        "format": "json",
      });

      final response = await dio.post(
        "upload?key=${AppConstants.apiKey}",
        data: formData,
      );

      return UploadedImageModel.fromJson(response.data["data"]);
    } on DioException catch (e) {
      throw DioFailure.fromDioException(e);
    }
  }

}
