import 'package:dartz/dartz.dart';
import '../../../../core/base_usecase/firebase_base_usecase.dart';
import '../../../../core/firebase/error/firebase_failure.dart';
import '../../data/responses/member_report_response.dart';
import '../repository/home_page_repository.dart';

class GetMemberReportUseCase extends FirebaseBaseUseCase {
  final HomePageRepository homePageRepository;

  GetMemberReportUseCase(this.homePageRepository);

  @override
  Future<Either<FirebaseFailure, List<MemberReportResponse>>> call(parameters) async {
    return await homePageRepository.getMemberReport(parameters);
  }
}