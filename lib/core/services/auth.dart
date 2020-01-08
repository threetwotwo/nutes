import 'package:nutes/core/models/user.dart';

class Auth {
  static Auth instance = Auth();

  UserProfile profile;

  String fcmToken;

  void reset() {
    Auth.instance = Auth();
  }
}
