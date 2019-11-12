import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nutes/ui/screens/editor_page.dart';

class CreateScreen extends StatefulWidget {
  @override
  _CreateScreenState createState() => _CreateScreenState();
}

class _CreateScreenState extends State<CreateScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Flexible(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    'Most Recent',
                    textAlign: TextAlign.start,
                    style:
                        TextStyle(fontSize: 40.0, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Container(
                height: 240,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: <Widget>[
                    AspectRatio(
                      aspectRatio: 1.0,
                      child: Container(
                        color: Colors.grey[300],
                        child: IconButton(
                          onPressed: _showUploadPage,
                          icon: Icon(
                            Icons.add,
                            size: 80,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showUploadPage() {
    Navigator.of(context, rootNavigator: true).push(CupertinoPageRoute(
      fullscreenDialog: true,
      builder: (context) {
        return EditorPage();
      },
    ));
  }
}

class DraftImage extends StatelessWidget {
  const DraftImage({
    Key key,
    @required this.widget,
    this.imageFile,
  }) : super(key: key);

  final CreateScreen widget;
  final File imageFile;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: AspectRatio(
          aspectRatio: 1.0,
          child: Container(
              color: Colors.grey,
              child: Image.file(
                imageFile,
                fit: BoxFit.fitWidth,
              )),
        ),
      ),
    );
  }
}
