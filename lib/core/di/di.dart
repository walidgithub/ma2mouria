import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:ma2mouria/features/auth/data/repository_impl/auth_repository_impl.dart';
import 'package:ma2mouria/features/home_page/data/data_source/home_page_datasource.dart';
import 'package:ma2mouria/features/home_page/data/requests/add_expense_request.dart';
import 'package:ma2mouria/features/home_page/domain/repository/home_page_repository.dart';
import 'package:ma2mouria/features/home_page/domain/usecases/add_cycle_usecase.dart';
import 'package:ma2mouria/features/home_page/domain/usecases/add_expense_usecase.dart';
import 'package:ma2mouria/features/home_page/domain/usecases/delete_cycle_usecase.dart';
import 'package:ma2mouria/features/home_page/domain/usecases/delete_expense_usecase.dart';
import 'package:ma2mouria/features/home_page/domain/usecases/get_active_cycle_usecase.dart';
import 'package:ma2mouria/features/home_page/domain/usecases/get_expenses_usecase.dart';
import 'package:ma2mouria/features/home_page/domain/usecases/get_members_usecase.dart';
import 'package:ma2mouria/features/home_page/domain/usecases/get_rule_usecase.dart';
import 'package:ma2mouria/features/home_page/domain/usecases/get_users_usecase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/preferences/app_pref.dart';
import '../../features/auth/data/data_source/auth_datasource.dart';
import '../../features/auth/domain/repository/auth_repository.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/home_page/data/repository_impl/home_page_repository_impl.dart';
import '../../features/home_page/domain/usecases/add_member_usecase.dart';
import '../../features/home_page/domain/usecases/delete_member_usecase.dart';
import '../../features/home_page/domain/usecases/logout_usecase.dart';
import '../../features/auth/presentaion/bloc/auth_cubit.dart';
import '../../features/home_page/presentaion/bloc/home_page_cubit.dart';


final sl = GetIt.instance;

class ServiceLocator {
  Future<void> init() async {
    // app prefs instance
    final sharedPrefs = await SharedPreferences.getInstance();
    sl.registerLazySingleton<SharedPreferences>(() => sharedPrefs);
    sl.registerLazySingleton<AppPreferences>(() => AppPreferences(sl()));

    // Firebase Auth
    final auth = FirebaseAuth.instance;
    sl.registerLazySingleton<FirebaseAuth>(() => auth);

    final firestore = FirebaseFirestore.instance;
    sl.registerLazySingleton<FirebaseFirestore>(() => firestore);

    // DataSources
    sl.registerLazySingleton<AuthDataSource>(() => AuthDataSource());
    sl.registerLazySingleton<HomePageDataSource>(() => HomePageDataSource());

    // Repositories
    sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));
    sl.registerLazySingleton<HomePageRepository>(() => HomePageRepositoryImpl(sl()));

    // UseCases
    // login useCases
    sl.registerLazySingleton<LoginUseCase>(() => LoginUseCase(sl()));

    //home useCases
    sl.registerLazySingleton<LogoutUseCase>(() => LogoutUseCase(sl()));
    sl.registerLazySingleton<GetRuleUseCase>(() => GetRuleUseCase(sl()));
    sl.registerLazySingleton<AddCycleUseCase>(() => AddCycleUseCase(sl()));
    sl.registerLazySingleton<AddMemberUseCase>(() => AddMemberUseCase(sl()));
    sl.registerLazySingleton<GetActiveCycleUseCase>(() => GetActiveCycleUseCase(sl()));
    sl.registerLazySingleton<DeleteCycleUseCase>(() => DeleteCycleUseCase(sl()));
    sl.registerLazySingleton<DeleteMemberUseCase>(() => DeleteMemberUseCase(sl()));
    sl.registerLazySingleton<GetMembersUseCase>(() => GetMembersUseCase(sl()));
    sl.registerLazySingleton<GetUsersUseCase>(() => GetUsersUseCase(sl()));
    sl.registerLazySingleton<AddExpenseUseCase>(() => AddExpenseUseCase(sl()));
    sl.registerLazySingleton<DeleteExpenseUseCase>(() => DeleteExpenseUseCase(sl()));
    sl.registerLazySingleton<GetExpensesUseCase>(() => GetExpensesUseCase(sl()));


    // Bloc
    sl.registerFactory(() => AuthCubit(sl()));
    sl.registerFactory(() => HomePageCubit(sl(), sl(), sl(), sl(), sl(), sl(), sl(), sl(), sl(), sl(), sl(), sl()));
  }
}