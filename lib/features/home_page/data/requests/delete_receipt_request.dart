import '../model/receipt_model.dart';

class DeleteReceiptRequest{
  String receiptId;
  String cycleName;
  String zone;
  DeleteReceiptRequest({required this.receiptId, required this.cycleName, required this.zone});
}