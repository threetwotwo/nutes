import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nutes/core/models/user.dart';
import 'package:nutes/ui/shared/provider_view.dart';
import 'package:nutes/ui/widgets/login_textfield.dart';
import 'package:nutes/core/services/repository.dart';
import 'package:nutes/ui/shared/styles.dart';
import 'package:nutes/utils/debouncer.dart';
import 'package:nutes/utils/responsive.dart';
import 'package:nutes/core/view_models/base_model.dart';
import 'package:nutes/core/view_models/login_model.dart';
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

  @override
  Widget build(BuildContext context) {
    double sized(double size) {
      return screenAwareSize(size, context);
    }

    double textSize = sized(15.0) < 15.0 ? 15.0 : sized(13.0);

    ///For use when checking if username exists during sign up
    final _debouncer = Debouncer(milliseconds: 500);

    return ProviderView<LoginModel>(
      builder: (context, model, child) => Scaffold(
          backgroundColor: Colors.white,
          body: Container(
            height: MediaQuery.of(context).size.height,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
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
                                controller: _usernameController,
                                onChanged: (model.isSigningIn)
                                    ? null
                                    : (text) => model.checkUsernameExists(text),
                                onSubmit: (model.isSigningIn)
                                    ? null
                                    : (text) => model.checkUsernameExists(text),
                              ),
                              PasswordField(
                                labelText: '',
                                controller: _passwordController,
                              ),
//                            PasswordTextField(
//                              controller: _passwordController,
//                            ),
                              if (!model.isSigningIn)
                                EmailTextField(
                                  controller: _emailController,
                                  onChanged: (text) =>
                                      model.checkIfEmailIsValid(text),
                                ),
                              SizedBox(height: sized(50.0)),
                              Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: <Widget>[
//                            SizedBox(height: sized(50.0)),
                                    Column(
                                      children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            model.errorMessage,
                                            textAlign: TextAlign.center,
                                            style: TextStyles.defaultDisplay
                                                .copyWith(
                                                    color: Colors.black87),
                                          ),
                                        ),
                                        LoginButton(
                                            usernameController:
                                                _usernameController,
                                            emailController: _emailController,
                                            passwordController:
                                                _passwordController,
                                            textSize: textSize),
                                      ],
                                    ),
                                    SizedBox(height: sized(20.0)),
                                  ],
                                ),
                              ),
                              SizedBox(height: 20.0),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    model.isSigningIn
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
                                      model.changeMode();
                                      model.setUsernameExists(false);
                                      print(model.isSigningIn);
                                    },
                                    child: Text(
                                      model.isSigningIn
                                          ? 'Register'
                                          : 'Sign In',
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
                            ],
                          )),
                    ]),
              ),
            ),
          )),
    );
  }
}

class LoginButton extends StatefulWidget {
  const LoginButton({
    Key key,
    @required TextEditingController usernameController,
    @required TextEditingController emailController,
    @required TextEditingController passwordController,
    @required this.textSize,
  })  : _usernameController = usernameController,
        _emailController = emailController,
        _passwordController = passwordController,
        super(key: key);

  final TextEditingController _usernameController;
  final TextEditingController _emailController;
  final TextEditingController _passwordController;
  final double textSize;

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
    super.initState();

    _animationController = AnimationController(
      duration: Duration(milliseconds: 60),
      vsync: this,
    );
    _animation = Tween(begin: 5.0, end: 4.7).animate(_animationController);
    _animationController.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<LoginModel>(context);
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTap: () async {
        print('tap login');

        ///remove any error messages
        model.setErrorMessage('');

        final username = widget._usernameController.text;
        final email = widget._emailController.text;
        final password = widget._passwordController.text;

        UserProfile userProf;
        if (model.isSigningIn) {
          userProf = await model.signIn(username: username, password: password);
        } else {
          await model.checkIfEmailIsValid(email);
          await model.checkUsernameExists(username);

          if (model.emailIsValid && !model.usernameExists) {
            userProf = await model.signUp(
              email: email,
              password: password,
              username: username,
            );
          } else
            return model.setErrorMessage(model.usernameExists
                ? 'Please '
                    'try another username'
                : model.emailIsValid
                    ? 'Please '
                        'try another email'
                    : 'Please enter a valid email');
        }
        Repo.currentProfile = userProf;
      },
      child: Column(
        children: <Widget>[
          SizedBox(height: _animation.value),
          Transform.scale(
            scale: _animation.value / 5,
            child: Container(
//        padding: EdgeInsets.all(_animationTween.value / 8 ?? 0),
              height: 40,
              child: Material(
                borderRadius: BorderRadius.circular(20),
                color: Colors.black.withOpacity(_animation.value - 4),
                elevation: _animation.value * 2,
                child: Center(
                  child: model.state == ViewState.Busy
                      ? SpinKitThreeBounce(
                          color: Colors.white,
                          size: 24,
                        )
                      : Text(
                          model.isSigningIn ? 'LOGIN' : 'SIGNUP',
                          style: TextStyles.W500Text15.copyWith(
                            color: Colors.white,
                            fontSize: widget.textSize,
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
