import 'package:dartz/dartz.dart';
import 'package:ma2mouria/features/home_page/domain/repository/home_page_repository.dart';

import '../../../../core/base_usecase/firebase_base_usecase.dart';
import '../../../../core/firebase/error/firebase_failure.dart';
import '../../data/model/cycle_model.dart';

class DeleteShareUseCase extends FirebaseBaseUseCase {
  final HomePageRepository homePageRepository;

  DeleteShareUseCase(this.homePageRepository);

  @override
  Future<Either<FirebaseFailure, void>> call(parameters) async {
    return await homePageRepository.deleteShare(parameters);
  }
}