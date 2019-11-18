import 'package:firebase_auth/firebase_auth.dart';
import 'package:nutes/core/models/user.dart';

class Auth {
  static Auth instance = Auth();

  String uid;
  FirebaseUser FIRUser;

  UserProfile profile;

  void reset() {
    Auth.instance = Auth();
  }
}
