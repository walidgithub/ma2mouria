import 'package:flutter/material.dart';
import '../constant/app_constants.dart';

void showSuccessSnackBar(BuildContext context, String messageBody) {
  final snackBar =  SnackBar(
      duration: Duration(milliseconds: AppConstants.durationOfSnackBar),
      backgroundColor: Colors.green,
      content: Text(messageBody));
  ScaffoldMessenger.of(Navigator.of(context, rootNavigator: true).context)
      .showSnackBar(snackBar);
}

void showErrorSnackBar(BuildContext context, String messageBody) {
  final snackBar =  SnackBar(
      duration: Duration(milliseconds: AppConstants.durationOfSnackBar),
      backgroundColor: Colors.redAccent,
      content: Text(messageBody));
  ScaffoldMessenger.of(Navigator.of(context, rootNavigator: true).context)
      .showSnackBar(snackBar);
}

void showWarningSnackBar(BuildContext context, String messageBody) {
  final snackBar =  SnackBar(
      duration: Duration(milliseconds: AppConstants.durationOfSnackBar),
      backgroundColor: Colors.deepOrangeAccent,
      content: Text(messageBody));
  ScaffoldMessenger.of(Navigator.of(context, rootNavigator: true).context)
      .showSnackBar(snackBar);
}
