import 'package:dartz/dartz.dart';
import 'package:ma2mouria/features/home_page/data/model/member_model.dart';
import 'package:ma2mouria/features/home_page/data/model/rules_model.dart';
import 'package:ma2mouria/features/home_page/data/model/receipt_model.dart';

import '../../../../core/base_usecase/firebase_base_usecase.dart';
import '../../../../core/firebase/error/firebase_failure.dart';
import '../repository/home_page_repository.dart';

class GetReceiptsUseCase extends FirebaseBaseUseCase {
  final HomePageRepository homePageRepository;

  GetReceiptsUseCase(this.homePageRepository);

  @override
  Future<Either<FirebaseFailure, List<ReceiptModel>>> call(parameters) async {
    return await homePageRepository.getReceipts(parameters);
  }
}