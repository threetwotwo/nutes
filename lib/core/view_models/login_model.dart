import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:nutes/core/models/user.dart';
import 'package:nutes/core/services/auth.dart';
import 'package:nutes/core/services/firestore_service.dart';
import 'package:nutes/core/services/locator.dart';
import 'package:nutes/core/services/repository.dart';
import 'package:nutes/core/view_models/base_model.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/services.dart';

class LoginModel extends BaseModel {
  final _auth = FirebaseAuth.instance;
  final _firestore = locator<FirestoreService>();

  //if false, user is in sign up mode
  bool _isSigningIn = true;

  bool get isSigningIn => this._isSigningIn;
  FirebaseAuth get auth => this._auth;
  Future<FirebaseUser> get currentUser => this._auth.currentUser();

  get onAuthStateChanged {
    return this._auth.onAuthStateChanged;
  }

  bool usernameExists = false;
  bool emailIsValid = true;

  String errorMessage = '';

  setErrorMessage(String message) {
    this.errorMessage = message;
    notifyListeners();
  }

  setUsernameExists(bool exists) {
    this.usernameExists = exists;
    notifyListeners();
  }

  setEmailIsValid(bool isValid) {
    this.emailIsValid = isValid;
    notifyListeners();
  }

  changeMode() {
    this._isSigningIn = !this._isSigningIn;
    errorMessage = '';
    notifyListeners();
  }

  Future<UserProfile> signIn({String username, String password}) async {
    setState(ViewState.Busy);

    bool noError = true;
    final user = await Repo.signInWithUsernameAndPassword(
            username: username, password: password)
        .catchError((e) {
      print(e);
      if (e is PlatformException) {
        String message;
        switch (e.code) {
          case 'ERROR_TOO_MANY_REQUESTS':
            message = 'Too many unsuccessful attempts. Please try again later.';
            break;

          case 'ERROR_WRONG_PASSWORD':
          case 'ERROR_USER_NOT_FOUND':
            message = 'Incorrect username or password';
            break;

          default:
            message = 'Cannot sign in. Please try again later.';
            break;
        }
        setErrorMessage(message);
        noError = false;
      }
    });

    if (user == null && noError)
      setErrorMessage('Incorrect username or password');
    setState(ViewState.Idle);
    return user;
  }

  Future<UserProfile> createUser({
    @required String email,
    @required String password,
    @required String username,
  }) async {
    setState(ViewState.Busy);
    final user = await Repo.createUser(
      username: username,
      password: password,
      email: email,
    );
    setState(ViewState.Idle);
    return user;
  }

  Future signOut() async {
    await _auth.signOut();
  }

  @override
  void dispose() {
    print('loginmodel disposed');
    super.dispose();
  }

  Future<bool> checkUsernameExists(String username) async {
    final exists = await _firestore.usernameExists(username);
    setUsernameExists(exists);
    return exists;
  }

  bool checkIfEmailIsValid(String email) {
    final isValid = EmailValidator.validate(email);
    setEmailIsValid(isValid);
    return isValid;
  }
}
