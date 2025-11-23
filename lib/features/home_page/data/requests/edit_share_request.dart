import '../model/receipt_members_model.dart';

class EditShareRequest{
  ReceiptMembersModel receiptMembersModel;
  String receiptId;
  String zone;
  EditShareRequest({required this.receiptMembersModel, required this.receiptId, required this.zone});
}