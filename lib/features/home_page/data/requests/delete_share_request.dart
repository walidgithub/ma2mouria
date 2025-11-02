import '../model/receipt_members_model.dart';

class DeleteShareRequest{
  ReceiptMembersModel receiptMembersModel;
  String receiptId;
  DeleteShareRequest({required this.receiptMembersModel, required this.receiptId});
}