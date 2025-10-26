import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/di/di.dart';
import '../model/user_model.dart';

abstract class BaseDataSource {
  Future<UserModel> login();
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

      final rulesRef = firestore.collection('rules');
      final existing = await rulesRef.where('email', isEqualTo: user.email).limit(1).get();

      if (existing.docs.isEmpty) {
        await rulesRef.doc(user.uid).set({
          'id': user.uid,
          'name': user.displayName ?? 'Unknown',
          'email': user.email,
          'photoUrl': user.photoURL,
          'rule': 'user',
        });
      }

      return UserModel.fromJson(userData);
    } catch (e) {
      rethrow;
    }
  }
}
