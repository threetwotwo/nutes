import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nutes/core/services/repository.dart';
import 'package:nutes/core/models/user.dart';
import 'package:nutes/ui/widgets/login_textfield.dart';
import 'package:nutes/ui/shared/styles.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();

  LoginScreen();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController(text: '');
  final _passwordController = TextEditingController(text: 'password');
  final _emailController = TextEditingController(text: '@gmail.com');

  bool isSigningIn = true;
  bool emailIsValid = true;
  bool usernameExists = false;
  String errorMessage = '';

  bool isLoading = false;

  void setErrorMessage(String s) {
    setState(() {
      errorMessage = s;
    });
  }

  void changeMode() {
    setState(() {
      this.isSigningIn = !this.isSigningIn;
      errorMessage = '';
    });
  }

  Future<bool> checkUsernameExists(String username) async {
    if (username.isEmpty) {
      setState(() {
        usernameExists = false;
      });
      return false;
    }
    final exists = await Repo.usernameExists(username);
    setState(() {
      usernameExists = exists;
    });
    return exists;
  }

  void checkIfEmailIsValid(String email) {
    final isValid = EmailValidator.validate(email);
    setState(() {
      emailIsValid = isValid;
    });
  }

  Future<UserProfile> createUser() async {
    final username = _usernameController.text;
    if (username.isEmpty) {
      setErrorMessage('Please enter a username');
      return null;
    }

    setState(() {
      isLoading = true;
    });
    final exists = await checkUsernameExists(username);

    if (exists) {
      setErrorMessage('Username taken. Please try another username');
      setState(() {
        isLoading = false;
      });
      return null;
    }

    final user = await Repo.createUser(
      username: username,
      password: _passwordController.text,
      email: _emailController.text,
    ).catchError((e) {
      if (e is PlatformException) {
        String message;
        switch (e.code) {
          case 'ERROR_EMAIL_ALREADY_IN_USE':
            message =
                'Email is already in use. Please try again with a different email';
            break;
          case 'ERROR_INVALID_EMAIL':
            message = 'Please enter a valid email';
            break;

          default:
            message = 'Cannot sign up. Please try again later';
        }
        setErrorMessage(message);
      }
    });

    setState(() {
      isLoading = false;
    });
    return user;
  }

  Future<UserProfile> signIn() async {
    final username = _usernameController.text;

    if (username.isEmpty) return null;

    setState(() {
      isLoading = true;
    });
    bool noError = true;
    final profile = await Repo.signInWithUsernameAndPassword(
            username: username, password: _passwordController.text)
        .catchError((e) {
      print(e);
      if (e is PlatformException) {
        String message;
        switch (e.code) {
          case 'ERROR_TOO_MANY_REQUESTS':
            message = 'Too many unsuccessful attempts. Please try again later';
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

    if (profile == null && noError)
      setErrorMessage('Incorrect username or password');

    setState(() {
      isLoading = false;
    });

    return profile;
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    double sized(double size) {
      return size;
    }

    return Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          height: MediaQuery.of(context).size.height,
          child: SingleChildScrollView(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    child: Stack(
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.fromLTRB(
                              sized(60.0), sized(110.0), 0.0, 0.0),
                          child: Text(
                            'nutes',
                            style: TextStyle(
                                fontSize: sized(80.0),
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                      padding: EdgeInsets.only(
                          top: sized(36.0),
                          left: sized(60.0),
                          right: sized(60.0)),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16)),
                      child: Column(
                        children: <Widget>[
                          UsernameTextField(
                            usernameExists: usernameExists,
                            controller: _usernameController,
                            onChanged: isSigningIn
                                ? null
                                : (text) {
                                    if (text.isEmpty)
                                      setState(() {
                                        usernameExists = false;
                                        return;
                                      });
                                    return checkUsernameExists(text);
                                  },
                            onSubmit: isSigningIn
                                ? null
                                : (text) => checkUsernameExists(text),
                          ),
                          PasswordField(
                            labelText: '',
                            controller: _passwordController,
                          ),
                          if (!isSigningIn)
                            EmailTextField(
                              controller: _emailController,
                              onChanged: (text) => checkIfEmailIsValid(text),
                            ),
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                Column(
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        errorMessage,
                                        textAlign: TextAlign.center,
                                        style: TextStyles.w600Text,
                                      ),
                                    ),
                                    LoginButton(
                                      isSigningIn: isSigningIn,
                                      isLoading: isLoading,
                                      usernameExists: usernameExists,
                                      emailIsValid: emailIsValid,
                                      onError: (e) {
                                        print(e);
                                      },
                                      onTap: () {
                                        setErrorMessage('');
                                        isSigningIn ? signIn() : createUser();
                                      },
                                    ),
                                  ],
                                ),
                                SizedBox(height: sized(20.0)),
                              ],
                            ),
                          ),
                          SizedBox(height: 20.0),
                        ],
                      )),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        isSigningIn
                            ? 'New to nutes?'
                            : 'Already have'
                                ' an account?',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                        ),
                      ),
                      SizedBox(width: 5.0),
                      InkWell(
                        onTap: () {
                          changeMode();
                          setState(() {
                            usernameExists = false;
                          });
                        },
                        child: Text(
                          isSigningIn ? 'Register' : 'Sign In',
                          style: TextStyle(
                            color: Colors.green,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 20.0),
                ]),
          ),
        ));
  }
}

class LoginButton extends StatefulWidget {
  final Function(String) onError;
  final bool emailIsValid;
  final bool usernameExists;
  final bool isSigningIn;
  final VoidCallback onTap;
  final bool isLoading;

  const LoginButton({
    Key key,
    this.onError,
    this.emailIsValid = true,
    this.usernameExists = false,
    this.isSigningIn,
    this.onTap,
    this.isLoading = false,
  }) : super(key: key);

  @override
  _LoginButtonState createState() => _LoginButtonState();
}

class _LoginButtonState extends State<LoginButton>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  Animation<double> _animation;

  void _onTapDown(TapDownDetails details) {
    _animationController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    print('on tap up');
    _animationController.reverse();
  }

  @override
  void initState() {
    _animationController = AnimationController(
      duration: Duration(milliseconds: 60),
      vsync: this,
    );
    _animation = Tween(begin: 5.0, end: 4.7).animate(_animationController);
    _animationController.addListener(() {
      setState(() {});
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
//    final model = Provider.of<LoginModel>(context);
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTap: () async {
        print('tap login');

        ///remove any error messages
        widget.onError('');

//        final username = widget._usernameController.text;
//        final email = widget._emailController.text;
//        final password = widget._passwordController.text;

        return widget.onTap();

//        UserProfile profile;
//        if (model.isSigningIn) {
//          profile = await model.signIn(username: username, password: password);
//          Auth.instance.profile = profile;
//        } else {
//          ///Create a new user
//          if (username.isEmpty)
//            return model.setErrorMessage('Username must not be empty');
//          model.checkIfEmailIsValid(email);
//          await model.checkUsernameExists(username);
//
//          if (model.emailIsValid && !model.usernameExists) {
//            await model.createUser(
//              email: email,
//              password: password,
//              username: username,
//            );
//            profile =
//                await model.signIn(username: username, password: password);
//            Auth.instance.profile = profile;
//          } else
//            return model.setErrorMessage(model.usernameExists
//                ? 'Please try another username'
//                : model.emailIsValid
//                    ? 'Please try another email'
//                    : 'Please enter a valid email');
//        }
      },
      child: Column(
        children: <Widget>[
          SizedBox(height: _animation.value),
          Transform.scale(
            scale: _animation.value / 5,
            child: Container(
              height: 40,
              child: Material(
                borderRadius: BorderRadius.circular(20),
                color: Colors.black.withOpacity(_animation.value - 4),
                elevation: _animation.value * 2,
                child: Center(
                  child: widget.isLoading
                      ? SpinKitThreeBounce(
                          color: Colors.white,
                          size: 24,
                        )
                      : Text(
                          widget.isSigningIn ? 'LOGIN' : 'SIGNUP',
                          style: TextStyles.w600Text.copyWith(
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
