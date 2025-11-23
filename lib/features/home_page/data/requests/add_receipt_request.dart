import 'package:ma2mouria/features/home_page/data/model/receipt_model.dart';

class AddReceiptRequest{
  ReceiptModel receipt;
  String cycleName;
  String zone;
  AddReceiptRequest({required this.receipt, required this.cycleName, required this.zone});
}