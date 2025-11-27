import 'package:dartz/dartz.dart';
import '../../../../core/base_usecase/dio_base_usecase.dart';
import '../../../../core/dio_error/dio_failure.dart';
import '../../data/model/upload_image_model.dart';
import '../repository/home_page_repository.dart';

class UploadImageUseCase extends DioBaseUseCase {
  final HomePageRepository homePageRepository;

  UploadImageUseCase(this.homePageRepository);

  @override
  Future<Either<DioFailure, UploadedImageModel>> call(parameters) async {
    return await homePageRepository.uploadImage(parameters);
  }
}