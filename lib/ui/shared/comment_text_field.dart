import 'package:flutter/material.dart';
import 'package:nutes/core/services/auth.dart';
import 'package:nutes/ui/shared/avatar_image.dart';
import 'package:nutes/ui/shared/styles.dart';

class CommentTextField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String hint;
  final Function(String) onSendPressed;

  const CommentTextField(
      {Key key, this.controller, this.focusNode, this.hint, this.onSendPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      color: Colors.white,
      child: Row(
        children: <Widget>[
          Container(
              width: 54,
              child: AvatarImage(
                  url: Auth.instance.profile.user.photoUrl, spacing: 0)),
          Expanded(
            flex: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      focusNode: focusNode,
                      controller: this.controller,
                      minLines: 1,
                      maxLines: 4,
                      maxLength: 800,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        counterText: '',
                        hintText: hint,
                      ),
                    ),
                  ),
                  InkWell(
                    borderRadius: BorderRadius.circular(200),
                    splashColor: Colors.white,
                    onTap: () {
                      if (this.controller.text.isEmpty ||
                          this.controller.text == null) return;
                      onSendPressed(controller.text);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Send',
                        style: TextStyles.w600Text
                            .copyWith(color: Colors.blueAccent),
                      ),
                    ),
                  ),
                ],
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(40),
                border: Border.all(color: Colors.grey[300], width: 1.4),
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
