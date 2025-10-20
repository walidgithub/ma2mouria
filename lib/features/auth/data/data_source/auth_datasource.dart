import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/di/di.dart';
import '../model/user_model.dart';

abstract class BaseDataSource {
  Future<UserModel> login();
  Future<void> logout();
}

class AuthDataSource extends BaseDataSource {
  final FirebaseAuth auth = sl<FirebaseAuth>();
  final FirebaseFirestore firestore = sl<FirebaseFirestore>();

  @override
  Future<UserModel> login() async {
    try {
      final googleProvider = GoogleAuthProvider();
      final userCredential = await auth.signInWithPopup(googleProvider);

      final user = userCredential.user!;
      final userData = {
        'id': user.uid,
        'email': user.email,
        'name': user.displayName,
        'photoUrl': user.photoURL,
      };

      return UserModel.fromJson(userData);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    try {
      await auth.signOut();
    } catch (e) {
      rethrow;
    }
  }
}
