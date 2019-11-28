import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nutes/core/services/auth.dart';
import 'package:nutes/core/services/repository.dart';
import 'package:nutes/ui/shared/avatar_image.dart';
import 'package:nutes/ui/shared/styles.dart';

class ShoutTextField extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onSendPressed;

  final _focusNode = FocusNode();

  ShoutTextField(
      {Key key, @required this.onSendPressed, @required this.controller})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
//        physics: NeverScrollableScrollPhysics(),
//        shrinkWrap: true,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: 100,
                height: 2,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.grey),
              ),
            ),

//          ListTile(
//            title: Text('What is the topic?'),
//            trailing: TextField(
//              decoration: InputDecoration(),
//            ),
//          ),
            Container(
//            height: 200,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Expanded(
                      child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: AvatarImage(
                        url: Auth.instance.profile.user.photoUrl, spacing: 0),
                  )),
                  Expanded(
                    flex: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 4, horizontal: 16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            Expanded(
                              child: TextField(
                                focusNode: _focusNode,
                                controller: this.controller,
                                minLines: 1,
                                maxLines: 10,
                                maxLength: 800,
                                decoration: InputDecoration(
                                    border: InputBorder.none,
                                    counterText: '',
                                    hintText: 'What would you like to say?'),
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
                                  style: TextStyles.W500Text15.copyWith(
                                      color: Colors.blueAccent),
                                ),
                              ),
                            ),
                          ],
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(40),
                          border:
                              Border.all(color: Colors.grey[300], width: 1.4),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Topic: ',
                    style: TextStyle(fontSize: 15, color: Colors.grey),
                  ),
                ),
                Expanded(
                    child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    maxLength: 120,
                    style: TextStyle(fontSize: 14, color: Colors.black),
                    decoration: InputDecoration(
                      counterText: '',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(999),
                        borderSide: BorderSide(
                          width: 0,
                          style: BorderStyle.none,
                        ),
                      ),
                      filled: true,
                      fillColor: Colors.grey[300],
                      hintText: 'Optional',
                      hintStyle: TextStyle(fontSize: 14, color: Colors.white),
                    ),
                  ),
                )),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
