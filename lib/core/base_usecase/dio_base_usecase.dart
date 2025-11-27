import 'package:equatable/equatable.dart';
import 'package:dartz/dartz.dart';
import 'package:ma2mouria/core/dio_error/dio_failure.dart';

abstract class DioBaseUseCase<T, Parameters> {
  Future<Either<DioFailure, T>> call(Parameters parameters);
}

class DioNoParameters extends Equatable {
  const DioNoParameters();
  @override
  List<Object?> get props => [];
}