import '../model/receipt_model.dart';

class DeleteReceiptRequest{
  String receiptId;
  String roundName;
  String zone;
  DeleteReceiptRequest({required this.receiptId, required this.roundName, required this.zone});
}