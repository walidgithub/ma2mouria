import 'package:dio/dio.dart';

class DioFailure {
  final String message;
  final int? statusCode;

  DioFailure({required this.message, this.statusCode});

  factory DioFailure.fromDioException(DioException e) {
    return DioFailure(
      message: e.message ?? "Unknown Dio Error",
      statusCode: e.response?.statusCode,
    );
  }

  @override
  String toString() => 'DioFailure(status: $statusCode, message: $message)';
}