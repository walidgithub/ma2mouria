import '../model/receipt_members_model.dart';

class EditShareRequest{
  ReceiptMembersModel receiptMembersModel;
  String receiptId;
  EditShareRequest({required this.receiptMembersModel, required this.receiptId});
}