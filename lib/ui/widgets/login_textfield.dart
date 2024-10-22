import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nutes/ui/shared/styles.dart';

final GlobalKey<FormFieldState<String>> _passwordFieldKey =
    GlobalKey<FormFieldState<String>>();

//String _validatePassword(String value) {
////  _formWasEdited = true;
//  final FormFieldState<String> passwordField = _passwordFieldKey.currentState;
//  if (passwordField.value == null || passwordField.value.isEmpty)
//    return 'Please enter a password.';
//  if (passwordField.value != value) return 'The passwords don\'t match';
//  return null;
//}

class PasswordField extends StatefulWidget {
  const PasswordField({
    @required this.controller,
    this.fieldKey,
    this.hintText,
    this.labelText,
    this.helperText,
    this.onSaved,
    this.validator,
    this.onFieldSubmitted,
  });

  final TextEditingController controller;
  final Key fieldKey;
  final String hintText;
  final String labelText;
  final String helperText;
  final FormFieldSetter<String> onSaved;
  final FormFieldValidator<String> validator;
  final ValueChanged<String> onFieldSubmitted;

  @override
  _PasswordFieldState createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            widget.labelText,
            style: TextStyles.defaultText.copyWith(
                color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ),
        TextFormField(
          controller: widget.controller,
          key: _passwordFieldKey,
          obscureText: _obscureText,
//      maxLength: 50,
          onSaved: widget.onSaved,
          validator: widget.validator,
          onFieldSubmitted: widget.onFieldSubmitted,
          decoration: InputDecoration(
            labelStyle: TextStyles.w600Text.copyWith(
              color: Colors.white,
              fontSize: 15,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                width: 0,
                style: BorderStyle.none,
              ),
            ),
            filled: true,
            fillColor: Colors.grey[200],
            hintText: 'Password',
            helperText: widget.helperText,
            suffixIcon: GestureDetector(
              dragStartBehavior: DragStartBehavior.down,
              onTap: () {
                setState(() {
                  _obscureText = !_obscureText;
                });
              },
              child: Icon(
                _obscureText ? Icons.visibility : Icons.visibility_off,
                color: Colors.black54,
                semanticLabel: _obscureText ? 'show password' : 'hide password',
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class PasswordTextField extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onChanged;

  const PasswordTextField({
    Key key,
    @required this.controller,
    this.onChanged,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return BaseTextField(
      obscureText: true,
      controller: controller,
      hint: 'Password',
      onChanged: onChanged,
    );
  }
}

class UsernameTextField extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onChanged;
  final Function(String) onSubmit;

  final bool usernameExists;

  const UsernameTextField({
    Key key,
    @required this.controller,
    this.onChanged,
    this.onSubmit,
    this.usernameExists = false,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
//    final model = Provider.of<LoginModel>(context);

    return BaseTextField(
      maxLength: 30,
      inputFormatters: [
        WhitelistingTextInputFormatter(RegExp("[a-z\._0-9]")),
      ],
      controller: controller,
      hint: 'Username',
      message:
          controller.text.isEmpty ? '' : usernameExists ? 'Username taken' : '',
      labelColor: usernameExists ? Colors.black : Colors.white,
      onChanged: onChanged,
      onSubmit: onSubmit,
    );
  }
}

class EmailTextField extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onChanged;
  final Function(String) onSubmit;

  final bool emailIsValid;
  final String message;

  const EmailTextField({
    Key key,
    @required this.controller,
    this.onChanged,
    this.onSubmit,
    this.emailIsValid = true,
    this.message = '',
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return BaseTextField(
      keyboardType: TextInputType.emailAddress,
      controller: controller,
      message: message.isNotEmpty
          ? message
          : emailIsValid ? '' : 'Enter a valid email',
      hint: 'Email',
      labelColor: emailIsValid ? Colors.white : Colors.black54,
      onChanged: onChanged,
      onSubmit: onSubmit,
    );
  }
}

class BaseTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final String message;
  final Color labelColor;
  final TextInputType keyboardType;
  final bool obscureText;
  final Function(String) onChanged;
  final Function(String) onSubmit;
  final TextCapitalization textCapitalization;
  final int maxLength;
  final List<TextInputFormatter> inputFormatters;
  const BaseTextField({
    Key key,
    @required this.controller,
    this.hint,
    this.labelColor = Colors.white,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.onChanged,
    this.onSubmit,
    this.textCapitalization = TextCapitalization.none,
    this.message,
    this.maxLength,
    this.inputFormatters,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            message ?? '',
            style: TextStyles.defaultText.copyWith(
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        TextField(
          inputFormatters: inputFormatters ?? null,
          autocorrect: false,
          textCapitalization: textCapitalization,
          maxLength: maxLength ?? 200,
          onChanged: onChanged,
          onSubmitted: onSubmit,
          obscureText: this.obscureText,
          keyboardType: keyboardType,
          controller: controller,
          style: TextStyles.defaultText,
          decoration: InputDecoration(
            counterText: '',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                width: 0,
                style: BorderStyle.none,
              ),
            ),
            filled: true,
            fillColor: Colors.grey[200],
            hintText: hint,
          ),
        ),
      ],
    );
  }
}
