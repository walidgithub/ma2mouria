import '../model/receipt_members_model.dart';

class DeleteShareRequest{
  ReceiptMembersModel receiptMembersModel;
  String receiptId;
  String zone;
  DeleteShareRequest({required this.receiptMembersModel, required this.receiptId, required this.zone});
}