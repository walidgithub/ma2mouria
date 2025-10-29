import '../model/receipt_model.dart';

class DeleteReceiptRequest{
  ReceiptModel receipt;
  String cycleName;
  DeleteReceiptRequest({required this.receipt, required this.cycleName});
}