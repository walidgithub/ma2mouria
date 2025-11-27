import 'package:ma2mouria/features/home_page/data/model/receipt_model.dart';

class AddReceiptRequest{
  ReceiptModel receipt;
  String roundName;
  String zone;
  AddReceiptRequest({required this.receipt, required this.roundName, required this.zone});
}