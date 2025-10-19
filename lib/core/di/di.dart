import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/preferences/app_pref.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../preferences/secure_local_data.dart';


final sl = GetIt.instance;

class ServiceLocator {
  Future<void> init() async {
    // app prefs instance
    final sharedPrefs = await SharedPreferences.getInstance();
    sl.registerLazySingleton<SharedPreferences>(() => sharedPrefs);
    sl.registerLazySingleton<AppPreferences>(() => AppPreferences(sl()));

    // Secure local data
    final secureStorage = FlutterSecureStorage();
    sl.registerLazySingleton<FlutterSecureStorage>(() => secureStorage);
    sl.registerLazySingleton<SecureStorageLoginHelper>(() => SecureStorageLoginHelper(sl()));

    // Firebase Auth
    // final auth = FirebaseAuth.instance;
    // sl.registerLazySingleton<FirebaseAuth>(() => auth);

    // final firestore = FirebaseFirestore.instance;
    // sl.registerLazySingleton<FirebaseFirestore>(() => firestore);

    // DataSources
    // sl.registerLazySingleton<WelcomeDataSource>(() => WelcomeDataSource());

    // Repositories
    // sl.registerLazySingleton<WelcomeRepository>(() => WelcomeRepositoryImpl(sl()));

    // UseCases
    // welcome useCases
    // sl.registerLazySingleton<LoginUseCase>(() => LoginUseCase(sl()));

    // Bloc
    // sl.registerFactory(() => SwitchUserCubit(sl(), sl(), sl(), sl()));
  }
}