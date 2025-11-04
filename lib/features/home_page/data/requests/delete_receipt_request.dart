import '../model/receipt_model.dart';

class DeleteReceiptRequest{
  String receiptId;
  String cycleName;
  DeleteReceiptRequest({required this.receiptId, required this.cycleName});
}